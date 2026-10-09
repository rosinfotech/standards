[![rosinfo.tech](https://cdn.rosinfo.tech/id/logo/id_logo_width_160.svg "rosinfo.tech")](https://rosinfo.tech)

# The Rosinfotech Base Standards

## The Documentation Standard

### Structure

- [Rule #2609270954 - Structured Descriptions: Progressive Disclosure](/standards/documentation-standard/rule-2609270954.md);

### References

- [Rule #2609270956 - Git References: Pin to Commit and Lines](/standards/documentation-standard/rule-2609270956.md);

### Formation

- [Rule #2609271055 - A Standard Is a Set of Rules](/standards/documentation-standard/rule-2609271055.md);

### Rules

- [Rule #2609271057 - Rule Naming and Schema](/standards/documentation-standard/rule-2609271057.md);

### Scheme

- [The rule scheme (template)](/standards/documentation-standard/assets/scheme.md);

## The Common Code Style Standard

### The Name Convention

#### Base principles

- [Rule #2103051010 - Unified Timestamp Label (UTLBL)](/standards/common-code-style-standard/rule-2103051010.md);
- [Rule #2103052001 - From General to Specific](/standards/common-code-style-standard/rule-2103052001.md);
- [Rule #2108211519 - Abbreviations in Uppercase](/standards/common-code-style-standard/rule-2108211519.md);

#### Files and directories

- [Rule #2601190149 - Directories: Kebab Case](/standards/common-code-style-standard/rule-2601190149.md);
- [Rule #2601190212 - Backend Files: Camel Case + Suffix](/standards/common-code-style-standard/rule-2601190212.md);
- [Rule #2601190214 - Bash Files: Snake Case](/standards/common-code-style-standard/rule-2601190214.md);
- [Rule #2601190331 - Frontend Files: Kebab Case](/standards/common-code-style-standard/rule-2601190331.md);
- [Rule #2601190333 - React Components: Camel Case](/standards/common-code-style-standard/rule-2601190333.md);

#### Variables

##### Paths and files

- [Rule #2108211636 - File Name with Extension: "File" Suffix](/standards/common-code-style-standard/rule-2108211636.md);
- [Rule #2108211643 - File Name without Extension: "FileNoExtension" Suffix](/standards/common-code-style-standard/rule-2108211643.md);
- [Rule #2108211646 - Directory Path: "Path" Suffix](/standards/common-code-style-standard/rule-2108211646.md);
- [Rule #2108211652 - Directory Name: "Directory" Suffix](/standards/common-code-style-standard/rule-2108211652.md);
- [Rule #2108211659 - Path to File: "PathFile" Suffix](/standards/common-code-style-standard/rule-2108211659.md);

#### Functions and methods

- [Rule #2109011651 - Function Arguments: Up to 3 Required + Options Object](/standards/common-code-style-standard/rule-2109011651.md);

### Sorting

- [Rule #2610031256 - Collections: Alphabetical Sorting](/standards/common-code-style-standard/rule-2610031256.md);

### Imports

- [Rule #2610031258 - Imports: Order, Hygiene, No Cycles](/standards/common-code-style-standard/rule-2610031258.md);

### Declarations

- [Rule #2610031260 - Declare Before Use, One per Statement, Prefer Const](/standards/common-code-style-standard/rule-2610031260.md);

### Expressions

- [Rule #2610031262 - Explicit Expressions and Canonical Shorthands](/standards/common-code-style-standard/rule-2610031262.md);

### Formatting

- [Rule #2610031264 - Line Formatting: Length 100, LF, No BOM](/standards/common-code-style-standard/rule-2610031264.md);
- [Rule #2610031266 - Empty Lines Discipline](/standards/common-code-style-standard/rule-2610031266.md);
- [Rule #2610031268 - Operator and Brace Spacing](/standards/common-code-style-standard/rule-2610031268.md);
- [Rule #2610031270 - Multiline Consistency](/standards/common-code-style-standard/rule-2610031270.md);

### Indentation

- [Rule #2609270950 - Indentation: 4 Spaces, No Tabs](/standards/common-code-style-standard/rule-2609270950.md);
- [Rule #2610031272 - Markdown Lists: Indentation Step 2](/standards/common-code-style-standard/rule-2610031272.md);

### Tabular data

- [Rule #2609270952 - Tabular Data: Prefer TSV over CSV](/standards/common-code-style-standard/rule-2609270952.md);

## The JavaScript Code Style Standard

### Variables

- [Rule #2605280102 - Unused Variables: Underscore Prefix](/standards/javascript-code-style-standard/rule-2605280102.md);

### Strings and Statements

- [Rule #2610031274 - String and Statement Formatting](/standards/javascript-code-style-standard/rule-2610031274.md);

### Tooling

- [Rule #2610031276 - Formatter Precedence: Prettier Owns the Layout](/standards/javascript-code-style-standard/rule-2610031276.md);

## The TypeScript Code Style Standard

### Types

- [Rule #2605280101 - Type Naming Prefixes: I, T, E, G](/standards/typescript-code-style-standard/rule-2605280101.md);

### Imports

- [Rule #2610031278 - Type-Only Imports: Separate Statement](/standards/typescript-code-style-standard/rule-2610031278.md);

## The React Code Style Standard

### Hooks

- [Rule #2610031280 - Hooks Discipline](/standards/react-code-style-standard/rule-2610031280.md);

### JSX

- [Rule #2610031282 - JSX Formatting](/standards/react-code-style-standard/rule-2610031282.md);

### Exports

- [Rule #2610031284 - Fast Refresh Exports](/standards/react-code-style-standard/rule-2610031284.md);

## The CSS Code Style Standard

### Formatting

- [Rule #2610031286 - Style Formatting](/standards/css-code-style-standard/rule-2610031286.md);

### Order

- [Rule #2610031288 - Property Order](/standards/css-code-style-standard/rule-2610031288.md);

## The Output CLI Standard

### Streams

- [Rule #2610072030 - Streams: stdout for Results, stderr for Diagnostics](/standards/output-cli-standard/rule-2610072030.md);
- [Rule #2610072032 - Exit Codes: 0 / 1 / 2](/standards/output-cli-standard/rule-2610072032.md);

### Color

- [Rule #2610072034 - Color: TTY and NO_COLOR Gating](/standards/output-cli-standard/rule-2610072034.md);
- [Rule #2610072036 - Color: Semantic Palette](/standards/output-cli-standard/rule-2610072036.md);
- [Rule #2610072038 - Color: Never Meaning by Color Alone](/standards/output-cli-standard/rule-2610072038.md);

### Typography

- [Rule #2610072040 - Headers: Marker Levels, Blue and White](/standards/output-cli-standard/rule-2610072040.md);
- [Rule #2610072042 - Lists: Dash Bullet, 4-Space Step, Terminators](/standards/output-cli-standard/rule-2610072042.md);
- [Rule #2610072044 - Blank Lines: Paragraph and Block Discipline, TTY Frame](/standards/output-cli-standard/rule-2610072044.md);
- [Rule #2610072046 - Line Width: 100 with Hanging Wrap](/standards/output-cli-standard/rule-2610072046.md);

### Messages

- [Rule #2610072048 - Message Prefixes: Error / Warning / Success / Information](/standards/output-cli-standard/rule-2610072048.md);
- [Rule #2610072050 - Paths: Relative, Quoted, path:line](/standards/output-cli-standard/rule-2610072050.md);

### Machine output

- [Rule #2610072052 - Machine Output: --tsv / --json Flags](/standards/output-cli-standard/rule-2610072052.md);

### Interaction

- [Rule #2610072054 - Progress: Single stderr Line with Final State](/standards/output-cli-standard/rule-2610072054.md);
- [Rule #2610072056 - Prompts: Question Line + Option Lines](/standards/output-cli-standard/rule-2610072056.md);

### Tooling

- [Rule #2610072058 - Enforcement: Approved Library per Stack](/standards/output-cli-standard/rule-2610072058.md);

### Demo

- [The executable reference implementation](/standards/output-cli-standard/assets/output-cli-demo.js);

## The Git Code Project Standard

### EditorConfig

- [Rule #2610031936 - EditorConfig: The Root File](/standards/git-code-project-standard/rule-2610031936.md);

### Makefile

- [Rule #2610031938 - Makefile: Vendoring the Framework](/standards/git-code-project-standard/rule-2610031938.md);

## The Git Flow Standard

### The ladder

- [Rule #2610082114 - The Flow Ladder: Five Named Variants](/standards/git-flow-standard/rule-2610082114.md);

### Common invariants

- [Rule #2610082116 - The Fork Point: the Merge Request Target](/standards/git-flow-standard/rule-2610082116.md);
- [Rule #2610082118 - Directions: the One-Way Flow and the Sync Discipline](/standards/git-flow-standard/rule-2610082118.md);
- [Rule #2610082120 - Hotfix: Delivery via main, Propagation by Back-Merge](/standards/git-flow-standard/rule-2610082120.md);

### Versioning

- [Rule #2610092122 - Versioning: Tags as the Version Truth and the Stamp Protocol](/standards/git-flow-standard/rule-2610092122.md);
- [Rule #2610092124 - Versioning: Changelog Fragments](/standards/git-flow-standard/rule-2610092124.md);
- [Rule #2610092126 - Versioning: The Stamp Commit Message](/standards/git-flow-standard/rule-2610092126.md);

### Variants

- [Rule #2610082122 - Variant #1: Trunk-Based Development](/standards/git-flow-standard/rule-2610082122.md);
- [Rule #2610082124 - Variant #2: GitHub Flow](/standards/git-flow-standard/rule-2610082124.md);
- [Rule #2610082126 - Variant #3: Git Flow Lite](/standards/git-flow-standard/rule-2610082126.md);
- [Rule #2610082128 - Variant #4: GitLab Flow Lite](/standards/git-flow-standard/rule-2610082128.md);
- [Rule #2610082130 - Variant #5: Git Flow](/standards/git-flow-standard/rule-2610082130.md);

### The repository marker

- [Rule #2610092156 - The Repository Marker: One File Declaring the Variant](/standards/git-flow-standard/rule-2610092156.md);

## The Security Standard

### Sensitive data

- [Rule #2609270958 - Sensitive Information: Never in Committed Files](/standards/security-standard/rule-2609270958.md);

## The AI Standard

### The User-AI Interaction Standard

- [Rule #2609271000 - Interactive Work: Step by Step](/standards/ai-standard/rule-2609271000.md);

### The AI Automation Standard

- [Rule #2609262015 - Git: No Write Operations Without an Explicit Order](/standards/ai-standard/rule-2609262015.md);
- [Rule #2609262020 - Sensitive Data: Scan Diffs Before Commit Proposals](/standards/ai-standard/rule-2609262020.md);
- [Rule #2609262025 - File References: Clickable Links Only](/standards/ai-standard/rule-2609262025.md);
- [Rule #2609262030 - Commit Requests: Preparation Flow Only](/standards/ai-standard/rule-2609262030.md);
- [Rule #2609262035 - Repository Initialization: Ask Before Init](/standards/ai-standard/rule-2609262035.md);

### AGENTS.md

- [Rule #2609262010 - The AGENTS.md Model: Base and Roles](/standards/ai-standard/rule-2609262010.md);
- [Rule #2609271528 - The BASE AGENTS.md: Composition](/standards/ai-standard/rule-2609271528.md);
- [Rule #2610031427 - AGENTS.md Inclusions: Role Assets from the Standards Repository](/standards/ai-standard/rule-2610031427.md);
- [Rule #2610031855 - New Project: Ask for the Workspace](/standards/ai-standard/rule-2610031855.md);
- [Rule #2610031908 - Agent Scripts: .agents Directory and Node.js](/standards/ai-standard/rule-2610031908.md);
- [Rule #2610051814 - Self-Criticism: Code - Verified Results](/standards/ai-standard/rule-2610051814.md);
- [Rule #2610051955 - Self-Criticism: Art - Drafts for the Owner's Review](/standards/ai-standard/rule-2610051955.md);
- [Rule #2610031647 - Git Manager AGENTS.md: Commits and Repository Initialization](/standards/ai-standard/rule-2610031647.md);
- [Rule #2610031649 - Technical Writer AGENTS.md: Progressive Disclosure and References](/standards/ai-standard/rule-2610031649.md);
- [Rule #2610031651 - Researcher AGENTS.md: Interactive Exploration](/standards/ai-standard/rule-2610031651.md);
- [Rule #2610042002 - Harness AGENTS.md: Spawned Agent Context](/standards/ai-standard/rule-2610042002.md);
- [Rule #2610051637 - Paid Services: Balance Report and Approvals](/standards/ai-standard/rule-2610051637.md);
- [Rule #2609271530 - Architect AGENTS.md: Whole Projects and Microservices](/standards/ai-standard/rule-2609271530.md);
- [Rule #2609271532 - Backend Engineer AGENTS.md: Go](/standards/ai-standard/rule-2609271532.md);
- [Rule #2609271534 - Backend Engineer AGENTS.md: Java](/standards/ai-standard/rule-2609271534.md);
- [Rule #2609271536 - Backend Engineer AGENTS.md: TypeScript (NodeJS)](/standards/ai-standard/rule-2609271536.md);
- [Rule #2609271538 - Frontend Engineer AGENTS.md: TypeScript + React](/standards/ai-standard/rule-2609271538.md);
- [Rule #2610081414 - CLI Engineer AGENTS.md: Command-Line Development](/standards/ai-standard/rule-2610081414.md);
- [Rule #2610081416 - CLI Output Contract: Binding Any Role to the Output CLI Standard](/standards/ai-standard/rule-2610081416.md);
- [Rule #2610082250 - Git Flow Expert AGENTS.md: Branching Model Stewardship](/standards/ai-standard/rule-2610082250.md);
