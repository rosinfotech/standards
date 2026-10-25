# Make Commands — the single input channel (all projects)

## The command line contract

- Every command target of the rosinfotech makefile framework - and every project command built on top of it - accepts user input through one channel only: `make <command> ["<one positional argument>"] [args="<flags>"]`;
- the positional slot carries at most one string (a message, a label, a version); passing two positional arguments is an error;
- flags travel only in the `args` make variable, lowercase, appended last in the recipe: `script.sh "<positional>" $(args)`;
- long `--kebab-case` forms are canonical; a single-letter short form exists only for high-frequency flags (`--yes` / `-y`);
- an unknown flag must fail with an error message and exit code 2 - silent ignoring is a violation;
- environment variables are not a command interface: the framework reads only industry signals (`NO_COLOR`, `CLICOLOR`, `TERM`, TTY detection) and its own internal transport;
- the framework parser `cliParseArgs` (in `lib_cli.sh`, delivered by `make vendor`) implements the contract for the framework commands; rich consumer CLIs keep their own parser under the same contract.

## The framework flag dictionary

- `--yes` / `-y` - auto-confirm every prompt of this invocation (agents, pipelines);
- `--release` - force the seal tag gate (tag now);
- `--defer` - defer the seal tag gate;
- `--force` - force `git_flow_clear` removal;
- `--redirected` - internal (the seal -> commit_push bridge), never advertised to users.

## Consumer repositories

- A repository that vendors the framework and adds its own command targets follows the same contract: input through `args="<flags>"`, at most one positional, unknown flags fail;
- the pass-through pattern is fixed: `$(call resolve_script,<script>.sh) [<positional>] $(args)` - flags are never named in the Makefile, the script's parser owns them;
- hints and usage strings inside consumer scripts must show the `args="..."` spelling, never an environment variable.
