<!-- markdownlint-disable MD041 -->

[![rosinfo.tech](https://cdn.rosinfo.tech/id/logo/id_logo_width_160.svg "rosinfo.tech")](https://rosinfo.tech)

# Changelog

<!-- markdownlint-disable MD024 -->

## [0.8.0] - 2026-10-25

### Added

- The Make Commands standard (the asset AGENTS-STANDARD-MAKE-ARGS.md): every command target of the rosinfotech makefile framework - and every project command built on top of it - accepts user input through one channel only: `make <command> ["<one positional argument>"] [args="<flags>"]`; the positional slot carries at most one string (a message, a label, a version), passing two positional arguments is an error; flags travel only in the args make variable, long `--kebab-case` forms are canonical, `--yes` / `-y` the single short form; an unknown flag must fail with an error message and exit code 2 - silent ignoring is a violation; environment variables are not a command interface (the framework reads only industry signals - NO_COLOR, CLICOLOR, TERM, TTY detection - and its own internal transport); the framework flag dictionary fixed: `--yes` / `-y` auto-confirm, `--release` force the seal tag gate, `--defer` defer it, `--force` force git_flow_clear removal, `--redirected` internal to the seal -> commit_push bridge; consumer repositories follow the same contract with the fixed pass-through pattern `$(call resolve_script,<script>.sh) [<positional>] $(args)` - flags are never named in the Makefile, hints show the `args="..."` spelling, never an environment variable;

### Changed

- The vendored makefile framework updated to 0.4.0 (the source commit 076d1ab): the framework commands switched from the environment-variable transport (FLOW_YES, FLOW_RELEASE, FLOW_CLEAR) to the args contract - the new cliParseArgs parser (lib_cli.sh) implements the single input channel for the framework commands, every git_flow script receives the one positional and the flags through it, the Makefile recipes append `$(args)` to every script call, the seal -> commit_push bridge rides `--redirected` instead of the env var; git_flow_prepare_release removed with its make target and its status mentions (the seal handles everything); the preassembled deferral branch of the seal dropped - the deferral applies uniformly; the secrets library gains secretsBackup - a timestamped rotating backup of the secrets file next to the original (SECRETS_BACKUP_KEEP copies kept, 3 by default);

## [0.7.0] - 2026-10-19

### Added

- Rule #2610191435: during commit preparation the agent assesses the documentation necessity - an ADR (`docs/adr/[lang_code]/*`) when the change embodies an architectural decision, a runbook (`docs/runbooks/[lang_code]/*`) when it introduces or alters an operational procedure; the degree of necessity at the agent's discretion (proposed with a one-line justification) or by a direct user instruction (drafted unconditionally); the naming, numbering, language and format follow the existing documents of the target directory, an empty or absent directory - the README language; the file edits are applied by the user, or by the agent on a separate explicit request;
- Rule #2609262030 and the asset AGENTS-STANDARD-GIT-MANAGER.md reference the assessment duty in the commit-preparation flow;

## [0.6.1] - 2026-10-17

### Changed

- The stamp protocol moved to seal-on-main for variants #4-#5 (Rules #2610082128, #2610082130, #2610092122, #2610092124, #2610092126): the fragments ride the gate branches unconsumed into main with the promotion; the seal assembles the CHANGELOG section on main right after the entry, lands the stamp commit with the tag in one atomic push and syncs the gates - the promotion merge-request title carries no version (the version arrives with the stamp commit, the same rhythm as #3), and the deferral applies to all variants;
- Rule #2610082130: the release train is singular in the tooling - the seal bumps the shipped train forward (release/x.y -> release/x.y+1); several manual trains remain an escape hatch, not the tooling path;
- Rule #2610082118: a gate branch whose content is fully promoted may be reset to main instead of merged - the tooling resets such gates during the seal;
- The variant, hotfix and stamp-protocol schemes redrawn in one style: the fragments ride the merge requests and the gates unconsumed, the seal is the process node on main (assemble, stamp, tag, gates sync, train bump), the fork bases are named in the task nodes;
- The ai-standard git section aligned with the amended Git Flow Standard and the makefile framework (Rules #2609262030, #2609262035, #2610031647; assets AGENTS-STANDARD-GIT-FLOW-EXPERT.md, AGENTS-STANDARD-GIT-MANAGER.md): the skill references renamed to skill-makefile-git-flow-ready; the commit-preparation flow now phase-aware (fragment proposals under variants #2-#5, the .version/CHANGELOG edits permitted to the agent only under a declared variant #1 per the skill's conditions); the versioning command proposal covers make git_flow_seal after gate merges; the Git Flow Expert asset rewritten - the marker names and location (.git_flow/.git-flow-*), the fragment path (.git_flow/changelog_fragments/), the develop naming, the seal-on-main assembly, the deferral in all variants, the singular train, the full variant names.

## [0.6.0] - 2026-10-11

### Changed

- The Git Flow Standard renamed to the Reviewed Merge to Release to Main Flow (Git Flow) Standard: the five variants now carry self-describing merge-path names - #1 Direct to Main Flow (Trunk-Based Development), #2 Free Merge to Main Flow (GitHub Flow), #3 Reviewed Merge to Main Flow (Git Flow Lite), #4 Reviewed Merge to Staging to Main Flow (GitLab Flow Lite), #5 Reviewed Merge to Release to Main Flow (Git Flow) - the canonical industry names stay in parentheses; the dev branch renamed to develop across the rules; the README index and the Git Flow Expert rule retitled accordingly;

- The repository marker (Rule #2610092156): the published regulating file is `.git_flow/flow` - the content copied as-is from the variant's asset, the directory is the discovery point, the file is the declaration; the five marker assets renamed to the new variant names (`.github-com-rosinfotech-direct-to-main-flow` through `.github-com-rosinfotech-reviewed-merge-to-release-to-main-flow`);

- The version truth (Rule #2610092122): the intended bump is declared in `.version` line 2 - a declared semver above the last tag is stamped as is (the bump granularity is the actor's choice), the steady state (line 2 equal to the last tag) means the default patch bump, a declaration below the tag-derived minimum is refused with an `Error`; the deferral for variants #1-#3 - every tagging is gated by a confirmation defaulting to deferral (a flag answers it for agents), the next confirmed stamp versions the accumulated work as one;

- The changelog fragments moved from `changelog-fragments/` in the repository root to `.git_flow/changelog_fragments/<UTLBL>.<type>.md` (Rule #2610092124);

### Added

- The squash discipline of the entry into main (Rule #2610092126): a task lands as one commit - #2 the squash merge carries the senior fragment message, #3 the squashed merge request carries no version and the stamp commit that follows brings it, #4-#5 the promotion squash is titled `$NEXT: <Type>: <message>` so main receives one versioned commit and the stamp only lands the tag; the task branch commits follow `<Type>: <message>`; a tag never travels without its commit - one atomic push of the branch and the tag;

- The Git Flow tooling vendored into the makefile framework: the `git_flow_*` make targets (init, status, stamp, prepare_release, task_start / task_finish / task_fragment / task_dev_merge, hotfix_start / hotfix_finish) backed by `flow_lib.sh` and `cli_lib.sh`; `version_get` resolves the next stamp from the tag floor and the `.version` intent (the Rule #2610092122 contract, the below-minimum refusal included); `version_show` reports the tag, the default floor, both `.version` lines and the resolved next stamp; `git_commit` and `git_commit_push` migrated to the CLI library output with the release gate, the deferral path and the atomic branch-and-tag push;

- The Output CLI Standard prompt bypass through make (Rule #2610072056): a command wrapped in make delivers the bypass as an inline environment variable - `make <target> VAR=1` or `VAR=1 make <target>` - the exported variable is the flag's transport;

## [0.5.5] - 2026-10-09

### Changed

- The repository markers of the Git Flow Standard (Rule #2610092156) now carry the rules list: after the `Flow:` and `Standard:` lines a `Rules:` block lists one URL per line - every rule of the standard that governs the variant and no others; the applicability matrix is fixed in the rule - #1 three rules (the variant, the stamp truth, the stamp message), #2 four (plus fragments), #3 six (plus the fork point and the sync, no hotfix rule - no queue), #4 and #5 seven (plus the hotfix);

- The assets norm (Rule #2609271055) gains the pointer asset exception: a file whose purpose is to declare and reference - not to carry norms (the flow markers) - carries the declaration and the URLs of the standard and its rules, inlines no norms; all other assets keep the purity rules; the Git Flow Expert asset syncs the marker content format;

- The marker prefix renamed from `.git-rosinfo-tech-*` to `.github-com-rosinfotech-*` - the prefix mirrors the standard's URL origin (`github.com/rosinfotech` -> `github-com-rosinfotech`), the single-marker detection stays a single glob;

## [0.5.4] - 2026-10-09

### Added

- The repository marker for the Git Flow Standard (Rule #2610092156): a repository declares its variant by exactly one root marker file - the five names are exhaustive (`.git-rosinfo-tech-trunk-based-development`, `.git-rosinfo-tech-github-flow`, `.git-rosinfo-tech-git-flow-lite`, `.git-rosinfo-tech-gitlab-flow-lite`, `.git-rosinfo-tech-git-flow`, canonical github / gitlab spelling); the content is two lines - `Flow: Variant #<N> - <Name>` and the link to the standard; more than one marker is a violation detected by globbing `.git-rosinfo-tech-*`; the lifecycle - created at the variant choice, updated by the very migration commit, audited first against the actual branch structure; agents read the marker as the input and never guess the flow from the history; the five ready-to-copy marker assets live in the standard's assets; the Git Flow Expert asset and rule inline the marker norms; the README index links the rule in the new The repository marker subsection;

## [0.5.3] - 2026-10-09

### Added

- The versioning layer for the Git Flow Standard (3 rules): tags as the version truth - the last committed version is read as `git describe --tags --abbrev=0` on the main tip, never from .version or CHANGELOG.md (both become generated artifacts of the stamp; the makefile version-update flow migrates to reading tags); the stamp protocol at the last gate - rebase on the main tip, read the tag, compute the next semver, assemble, `git push --atomic` with the duplicate-tag rejection as the retry loop; the granularity map - version-per-merge for variants #1-#4, version-per-release for #5 (x.y.0 at the release merge, x.y.z+1 for hotfixes); the assembly location split - the stamp on main for #1-#3, the assembly commit in the gate branch for #4-#5 so main never sees raw fragments; changelog fragments - `changelog-fragments/<UTLBL>.<type>.md`, one line per task, consumed by the stamp, the dev copies carried by the merges and the standing sync; the stamp commit message `$NEXT: <Type>: <main message>` with merge commits carrying no version prefix;

- The five variant rules gain their versioning sections, the Git Flow Expert asset and its rule (Rule #2610082250) inline the versioning norms and map the new rules; the README index links the Versioning subsection;

## [0.5.2] - 2026-10-08

### Changed

- The blank-line discipline of the Output CLI Standard (Rule #2610072044): exactly one blank line after every paragraph and after every message line or block (Error / Warning / Success / Information) before any following content; the guarantee against two or more consecutive blank lines now covers the whole own output; the relay exception formalized - a retransmitted utility output (df, systemctl, docker ...) passes through as-is and is framed by exactly one blank line before and after it; the message rule (Rule #2610072048) cross-references the discipline; the demo asset gains the maintenance scenario (a server report with a warning-disclosed list and a relayed df -h block); the CLI Engineer asset syncs the inlined norm;

## [0.5.0] - 2026-10-08

### Added

- The Git Flow Standard (9 rules, `standards/git-flow-standard/`): the ladder of five named variants - Trunk-Based Development, GitHub Flow, Git Flow Lite, GitLab Flow Lite, Git Flow - picked by two questions: how many people and how many gates stand between a commit and production; the common invariants: the fork point equals the merge-request target (gated dirt of staging / release/x.y is a legal fork base, ungated dirt of dev is the only forbidden one), the one-way task flow with dev as a dead-end integration sink, the sync discipline (main -> dev after every promotion), and the hotfix contract - delivery via main bypassing the queue, propagation by back-merge into staging / release/x.y and dev; every variant rule carries its mermaid scheme, the environment mapping (dev / stage / prod), the hotfix behavior and the listed deviations from the canon; the README index links the standard's nine rules after The Git Code Project Standard;

## [0.5.1] - 2026-10-08

### Added

- The Git Flow Expert role (Rule #2610082250, the asset AGENTS-STANDARD-GIT-FLOW-EXPERT.md - isolated and self-contained, the norms inlined as plain text): the branching-model stewardship split from the git operations stewardship of the Git Manager - the ladder of five variants, the fork-point invariant with the gated / ungated dirt classification, the one-way flow with the sync discipline, the hotfix contract and the per-variant contracts live in one role asset; the rule maps every asset section to the Git Flow Standard rules, and the README index links it in the AGENTS.md subsection;

## [0.4.10] - 2026-10-08

### Added

- The Output CLI Standard (15 rules, `standards/output-cli-standard/`): streams (stdout for results, stderr for diagnostics) and exit codes 0 / 1 / 2; color gating by TTY / NO_COLOR / CLICOLOR with the fixed switch precedence; the closed semantic palette - header blues and white (94 / 97), fully colored messages, JSON syntax roles; marker heading levels (`==` / `--` / flat) chosen by the section weight with the content restarting at column 0; lists with the 4-space step and the `;` / `:` terminator discipline; the blank-line discipline with the TTY frame; line width 100 with the hanging wrap; message prefixes Error / Warning / Success / Information with the multi-sentence block layout; relative quoted paths as `path:line`; machine modes `--tsv` / `--json` with pretty JSON in a TTY and compact in pipes; single-line progress and numbered prompts; the approved library list per stack; the executable reference implementation lives in the standard's assets (output-cli-demo.js);

- The CLI Engineer role (Rule #2610081414, the asset AGENTS-STANDARD-ENGINEER-CLI.md - isolated and self-contained, the norms inlined as plain text) and the CLI output contract binding any role that touches a CLI to the standard (Rule #2610081416);

### Changed

- The assets isolation norm (Rule #2609271055): assets carry no references to rules - the norms are inlined as plain text, the description lives in the rules;

- The README index items now follow the list terminator grammar (`;` / `:`), the new standards and rules linked;

## [0.4.9] - 2026-10-05

### Added

- The self-criticism norm, split by domain: Code (Rule #2610051814 - verified results, the checks, the evidence) and Art (Rule #2610051955 - creative work without a test suite: the brief self-review, the craft basics, the drafts for the owner's review, the variants with the recommendation); the BASE core gains the seventh section covering both domains - the confidence is born only from a result confirmed by the owner;

## [0.4.8] - 2026-10-05

### Added

- The paid services norm (Rule #2610051637, the Harness role): before every paid action - via an API or MCP - the agent reports the current balance and the predicted charge; the report is always shown, an approval (action / task / day / full) suppresses only the request, never the report;

## [0.4.7] - 2026-10-04

### Added

- The Harness functional role (Rule #2610042002, the asset AGENTS-STANDARD-HARNESS.md): when the agent platform spawns another agent, it must create AGENTS.md in the spawned agent's context - the BASE composed per Rule #2609271528, fetched from the asset; the spawned agent starts from the clean base and composes role inclusions on demand;

## [0.4.6] - 2026-10-03

### Added

- The Git Code Project Standard: the EditorConfig root file rule (#2610031936, with the ready-to-copy asset) and the makefile vendoring rule (#2610031938, `make vendor` from a clone of rosinfotech/makefile);

- The Git Manager priority part: the git project setup (EditorConfig + the vendoring) comes before the commit and initialization flows (Rule #2610031647, the asset section);

## [0.4.5] - 2026-10-03

### Added

- The agent scripts norm (Rule #2610031908): ad-hoc helper scripts for micro-tasks live in the `.agents/` directory of the project root and run on Node.js regardless of the project stack; the dependency discipline - prefer Node built-ins (zero-dependency), unavoidable dependencies install inside `.agents/`, never in the project root; the BASE core gains the sixth section;

## [0.4.4] - 2026-10-03

### Added

- The new project workspace norm (Rule #2610031855): a production task on a new project triggers the workspace question - create a separate directory or work in an existing one - only when no explicit directory was communicated and the contextual directory carries no project markers; the BASE core gains the fifth section;

## [0.4.3] - 2026-10-03

### Added

- The AGENTS.md self-update: on the user's request ("обнови AGENTS.md") the agent refreshes everything the file takes from the standards repository - the core zone is replaced with the current BASE asset, every marked inclusion block is re-fetched; custom content outside the core zone and the blocks stays untouched (the model Rule #2609262010, the BASE asset section);

## [0.4.2] - 2026-10-03

### Changed

- The AGENTS.md model (#2609262010) and the related rules are fully composition-terminology now: the behavioral core plus the role assets composed in as marked blocks on demand - no inheritance wording ("extends", "role file") is left; the composition precedence: the BASE core is never overridden by an included block;

## [0.4.1] - 2026-10-03

### Changed

- The role AGENTS.md assets are isolated: the "Extends the BASE AGENTS.md; never weakens it" blockquote and every in-body base reference removed - each role file is self-contained and usable standalone;

- The Git Manager asset carries its own git safety phrasings instead of deferring to the BASE section;

## [0.4.0] - 2026-10-03

### Added

- The AGENTS.md inclusions mechanism (Rule #2610031427): the include command refreshes the link base (the asset listing of the standards repository), updates the existing marked blocks and appends the semantically closest role asset - the composition is operable in place;

- The functional roles, split out of the BASE AGENTS.md, with ready-to-copy assets:

  - Git Manager (Rule #2610031647) - the commit preparation flow and the repository initialization;

  - Technical Writer (Rule #2610031649) - progressive disclosure woven first, the file references second;

  - Researcher (Rule #2610031651) - the interactive step-by-step work;

### Changed

- The BASE AGENTS.md is the behavioral core now - exactly three sections: AGENTS.md inclusions, Sensitive information, Git - the absolute prohibition; everything else is included from the role assets on demand (Rule #2609271528);

- The role model (#2609262010) distinguishes the functional roles and the engineering roles;

## [0.3.2] - 2026-10-03

### Changed

- The role AGENTS.md assets are self-contained instructions now: the full meaning of every included rule inlined as text, no rule IDs and no catalog links - an agent has nothing to fetch or analyze;

- The TypeScript backend and frontend assets carry the Lints section with the explicit lint config repository URLs to apply in repositories (4 and 6 repositories respectively);

- The rule inclusion model (#2609262010) and the BASE composition (#2609271528) reformulated: the full meaning over the reference; rule IDs and links appear only where the file needs them on purpose;

## [0.3.1] - 2026-10-03

### Changed

- The progressive disclosure rule (#2609270954) explicitly covers inline enumerations after a colon - the colon is the disclosure marker; the affected items across the catalog restructured into sublists;

- The code examples re-audited against their own rules: 4-space indentation inside code fences everywhere (Rules #2103052001, #2109011651, #2605280102, #2610031286) and the Correct examples fixed to comply - the imports block of Rule #2610031258, the JSX props order of Rule #2610031282, the numeric literal of Rule #2610031262, the declaration syntax of Rule #2610031260, the length label of Rule #2610031264, the quotes of Rule #2605280101;

## [0.3.0] - 2026-10-03

### Added

- The lint standards: 17 new rules extracted from the shared lint configs (prettier-config-standard, eslint-config-javascript, eslint-config-import, eslint-config-typescript, eslint-config-react, stylelint-config-standard) - every rule names the repository that supports it (the Enforcement note);

- The Common Code Style Standard subsections: Sorting, Imports, Declarations, Expressions, Formatting (4 rules) and the Markdown lists exception (indentation step 2 in `*.md`, the documented exception of Rule #2609270950);

### Changed

- The language-specific rules moved out of the common standard into per-language standards: The JavaScript, TypeScript, React and CSS Code Style Standards - the Common Code Style Standard now carries only universal rules;

- Rule #2605280102 (unused variables: underscore prefix) scope extended from TypeScript to JavaScript and TypeScript;

- The role AGENTS.md rules and assets (#2609271530 - #2609271538) include the new rule sets: universal rules for every role, the language standards for the TypeScript backend and the React frontend;

- The import cycles are forbidden: the no-cycle norm is part of the Imports rule (Rule #2610031258), the eslint-config-import repository enables it;

## [0.2.1] - 2026-10-02

### Changed

- Restructured the inline enumerations into nested lists per the progressive disclosure rule (Rule #2609270954): the code style rule sets of the role rules #2609271530 - #2609271538, the design scales of the architect rule and the scheme sections of Rule #2609271057;

- Restructured the path/file suffix and naming lines of the role AGENTS.md assets into nested lists;

## [0.2.0] - 2026-09-27

### Changed

- Replaced the two-level AGENTS.md model with the Base and Roles model: the BASE AGENTS.md plus independent role files, project-specific knowledge is read from the repository itself (Rule #2609262010 rewritten);

- Made the assets pure ready-to-copy files (the rule scheme and the AGENTS files) - their description moved entirely into the rules (Rules #2609271055, #2609271057);

- The role AGENTS.md files and their rules now include the full per-language set of the Common Code Style Standard rules with explicit exclusions (Rules #2609271530 - #2609271538);

- Explicit GitHub links to the makefile ai-skills in the commit and repository initialization rules and in the BASE asset (Rules #2609262030, #2609262035);

### Added

- The AGENTS.md subsection of the AI standard: the BASE AGENTS.md composition (Rule #2609271528) and the role rules with ready-to-copy assets: architect (#2609271530), backend Go (#2609271532), backend Java (#2609271534), backend TypeScript/NodeJS (#2609271536), frontend TypeScript + React (#2609271538, the stack from the company frontend boilerplates);

### Removed

- The Project AGENTS.md level: Rule #2609271120, the AGENTS-STANDARD-2.md skeleton and the numbered asset naming (AGENTS-STANDARD-1.md);

## [0.1.0] - 2026-09-27

### Changed

- Restructured the standards catalog: renamed docs/ to standards/, moved the master index into README.md, reorganized into four standards (Documentation, Common Code Style, Security, AI) whose folders mirror the index sections with the -standard suffix;

### Added

- The AI standard: the AGENTS.md hierarchy of two levels (Rule #2609262010) with the level assets AGENTS-STANDARD-1.md and AGENTS-STANDARD-2.md;
- Rules #2609262015 - #2609262035: agent behavior and workflow (git write prohibition, sensitive data diff scan, clickable file references, commit preparation flow, repository initialization);
- Rules #2609270950 and #2609270952: indentation of 4 spaces and TSV over CSV;
- Rules #2609270954 and #2609270956: progressive disclosure in structured descriptions and git references pinned to commit and lines;
- Rules #2609270958, #2609271000 and #2609271120: sensitive information, interactive step-by-step work, Project AGENTS.md composition;
- Rules #2609271055 and #2609271057: standard formation and rule naming/schema, with the rule scheme asset;

### Removed

- The docs/ folder structure, the Figma MCP example from the Project AGENTS.md skeleton and Kilo-specific references;

## [0.0.11] - 2026-09-26

### Changed

- Makefile now uses self-contained vendored framework from .makefile/vendor/rosinfotech instead of globally linked scripts;

### Removed

- Old globally linked .makefile scripts and project-specific docker/deploy Makefile targets;

## [0.0.10] - 2026-05-28

### Added

- Rules #2605280101 and #2605280102: TypeScript type naming prefixes (I, T, E, G) and unused variables with underscore prefix;

## [0.0.9] - 2026-05-28

### Changed

- Added descriptive titles to all rule links in The Base Programming Standards;

## [0.0.8] - 2026-01-19

### Fixed

- Logo at the top of the index page;

## [0.0.7] - 2026-01-19

### Added

- Added set of rules Name Convention / Files and directories;

## [0.0.6] - 2026-01-17

### Added

- 2103051010: Rule: Unified Timestamp Label (UTLBL) - simple approach to unique identify anything;

## [0.0.5] - 2026-01-17

### Improved

- Rules decomposition;

## [0.0.4] - 2026-01-17

### Added

- Makefile commands;
