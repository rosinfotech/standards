<!-- markdownlint-disable MD041 -->

[![rosinfo.tech](https://cdn.rosinfo.tech/id/logo/id_logo_width_160.svg "rosinfo.tech")](https://rosinfo.tech)

# Changelog

<!-- markdownlint-disable MD024 -->

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
