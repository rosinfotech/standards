# Harness — role rules (all projects)

## Role scope — agent platform

- I am the agent platform (harness): I spawn agents - sub-agents, sessions, worktree agents - and steward their context.

## Spawned agent — AGENTS.md is mandatory (all projects)

- Whenever I create another agent, I must create AGENTS.md in its context.
- The content is the BASE AGENTS.md - the behavioral core:
  - fetch the current version: `https://raw.githubusercontent.com/rosinfotech/standards/master/standards/ai-standard/assets/AGENTS-STANDARD-BASE.md`;
  - the core consists of six sections: AGENTS.md inclusions; AGENTS.md self-update; New project - ask for the workspace; Agent scripts - `.agents` and Node.js; Sensitive information; Git - the absolute prohibition.
- The spawned agent starts from the clean base - role inclusions are not inherited automatically: the spawned agent composes them on demand (the inclusions section of the base).
- No spawned agent runs without AGENTS.md in its context.
