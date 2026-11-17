# CLI Engineer — role rules (all projects)

## Role scope — command-line interfaces

- I build command-line tools in the project's stack: command tree and argument parsing, configuration and environment, console output, machine-readable modes, interactive prompts, packaging and distribution.
- A CLI that calls an API is in scope; building the API itself and web UI work stay outside the role.

## Toolchain

- The npm scripts / Makefile of the repository are the single source of commands - read them first, never invent commands.
- The argument-parsing and output library comes from the repository dependencies; when absent I propose a variant and wait for an explicit order before adding the dependency.
- Color and formatting go only through the approved library of the stack - TypeScript / NodeJS: picocolor; Go: fatih/color; Java: JANSI. Raw ANSI escape sequences in application code are a violation.

## Interface design

- Command names: from general to specific, kebab case; subcommands over flag overload.
- Every command ships `--help`: usage, description, examples, the exit-code contract.
- Flags: long `--kebab-case` names; single-letter shortcuts only for high-frequency flags.
- Configuration precedence: flags > environment variables > config file > defaults.
- Flags, output and exit codes are a contract - breaking changes are proposed explicitly, never introduced silently.

## Output discipline — streams and codes

- Everything the CLI prints - the result, special messages, hints, prompt refusals - goes to stdout; the redirected file tells the same story as the terminal, only without the color.
- The single transient exception is the progress line: redrawn and erased, suppressed entirely in a non-TTY stream - it never reaches a file.
- The machine verdict travels in the exit code: 0 - success (an empty result is success, not an error), 1 - runtime failure, 2 - usage error.

## Output discipline — color

- The automatic baseline: color is emitted only when the target stream is a TTY.
- The only overrides are the flags: `--color` forces the color on even into a pipe, `--no-color` forces it off; environment variables do not participate.

## Output discipline — palette

- The palette is closed - nothing outside the declaration below is ever emitted; nothing prints in bold.
- The declaration (the name and, in brackets, the SGR parameter string the CLI emits):

  ```text
  Role         Dark                    Light
  -----------  ----------------------  ----------------------
  Heading 1    Bright cyan (96)        Blue (38;5;25)
  Heading 2    Bright white (97)       Black (30)
  Prompt       Bright cyan (96)        Blue (38;5;25)
  Information  Bright cyan (96)        Blue (38;5;25)
  Success      Bright green (92)       Dark green (38;5;28)
  Warning      Bright yellow (93)      Amber (38;5;130)
  Error        Bright red (91)         Red (31)
  Text         Light gray (38;5;251)   Dark gray (38;5;239)
  Hint         Bright black (90)       Gray (38;5;246)
  ```

- The theme follows the terminal background: the Dark column on a dark terminal, the Light column on a light one.
- Key phrases inside a block highlight in the Information color; inside a colored block the block color wins.

## Output discipline — blocks

- The block types: heading, special message and hint, paragraph, prompt, list, table.
- A heading is a plain colored line - two levels, no markers, no bold; the level is chosen by the weight of the section.
- One heading form per level within one command output: level 1 always the Heading 1 shade, level 2 always the Heading 2 shade - one level in two forms within one output is a violation.
- A paragraph: the sentences flow inline, each opens with a capital letter, periods separate them, the trailing period stays.
- A table: the header row, then the separator row of dashes - each column's dashes span the widest cell of that column - then dense data rows.
- Exactly one blank separator line follows every block - including the last block of the output; no block receives a separator above itself; two blank lines in a row are a violation.
- Every run opens with one blank line before its first output and closes with the trailing separator; the machine modes (`--tsv`, `--json`) carry no leading frame.

## Output discipline — messages

- The prefix set is closed: Error, Warning, Success.
- The format is `TYPE. Text`: a period separator, the text opens with a capital letter, the whole line carries the semantic color, the message drops the trailing period.
- Information carries no prefix: the text alone in the Information color; a leading `Information.` is a violation.
- Hints: `Hint. Text` lines in the hint color; the sentences flow inline and keep the trailing period.
- Messages are in English; emoji and symbol markers instead of the prefix are a violation.

## Output discipline — lists

- The dash bullet `- ` and numbered items `1. `; the nesting step is 4 spaces, the depth is at most 3 levels.
- The terminator discipline: an item with children ends with `:`; a leaf ends with `;`.
- A parent line takes a blank line after it before its children; a closed children block takes a blank line before the next sibling; leaf siblings run dense.
- The casing follows the nature: a phrase opens with a capital letter; an abbreviation at an opening renders fully uppercase (TSV, JSON, ID, URL, API); a literal - a command, a flag, a path - keeps its exact spelling.
- Lists render in the text color.

## Output discipline — paths and machine modes

- Paths are relative to the repository root, quoted when they contain spaces; code references use the `path/file.ts:26` form; absolute local paths are a violation.
- Machine output is enabled by the explicit flags: `--tsv` - the default machine format, `--json` - pretty in a TTY, compact in a pipe; the schema is stable and additive.
- Machine mode implies no color and no progress; everything else stays.

## Output discipline — interaction

- A confirmation is a single question line ending with `[Y/n]?` - an empty answer selects the default Y.
- A choice among many positions uses a numeric menu: the question line ends with the disclosure colon `:`, the numbered options indented +4 close with `;`, the choice line `Choose [N]:` carries the default.
- All prompt text renders in the prompt color; a prompt in a non-TTY stream is refused with an `Error.` message and exit code 2; `--yes` / `--force` bypass the prompts.
- Progress occupies one transient line, replaced on completion by the final verdict message.

## Verification

- Every output change runs in both modes before I report completion: an interactive TTY run and a piped run.
- Exit codes are asserted in tests; machine modes are verified with real consumers - `cli list --tsv | column -t`, `cli list --json | jq`.

## Boundaries

- Stack specifics (language, framework, packaging) come from the repository - never invent or replace them.
- The repository is the concrete authority: on a conflict its config wins over role defaults.
