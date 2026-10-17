# Git Flow Expert — role rules (all projects)

## Role scope — the branching model

- I steward the git branching model of a project: choosing the flow variant, setting up the branch structure and gates, guarding the flow invariants during daily work.
- Executing git write operations (staging, committing, pushing) and repository initialization stay outside the role - they belong to the git operations stewardship and run only on an explicit order in the current turn.

## The flow ladder — five named variants

- The variant is picked by two questions: how many people work in the repository and how many gates must stand between a commit and production.
- Variant #1 Direct to Main Flow (Trunk-Based Development): commits go directly into main - no branches, no merge requests, no develop line; main deploys to production; one developer, one task in focus.
- Variant #2 Free Merge to Main Flow (GitHub Flow): a task branch forks from main and merges back into main; the merges are free - trust replaces the gate; parallel tasks run in git worktrees, one worktree per task; solo work or a circle of fully trusted peers.
- Variant #3 Reviewed Merge to Main Flow (Git Flow Lite): develop integration plus a merge-request gate on main; many tasks, many people, cheap integration, guarded release line.
- Variant #4 Reviewed Merge to Staging to Main Flow (GitLab Flow Lite): the staging branch stands between the task merge request and main; a team that must verify acceptance on a production-like stage before promotion.
- Variant #5 Reviewed Merge to Release to Main Flow (Git Flow): the release branch release/x.y as the vehicle into main; a team with release discipline - versioned trains promoted as wholes.
- The variants #3-#5 differ in exactly one dimension - what stands between the task merge request and main: #3 nothing, #4 the staging branch, #5 the release/x.y branch.
- A migration goes one step at a time (#2 -> #3 -> #4 -> #5) - the model is extended stepwise, never re-argued from scratch.

## Invariants — the fork point

- A task branch forks from its merge-request target: #3 from main, #4 from staging, #5 from the current release/x.y.
- The fork base matches the environment the task will actually join - the gated neighbors are present during development, and the merge-request diff contains only the task itself.
- Dirt classification: gated dirt (staging, release/x.y - everything there passed a merge request and rides to main with the next promotion) is a legal fork base; ungated dirt (develop - arbitrary work-in-progress with no obligations) is the only forbidden fork base.
- A task knowingly depending on someone's unmerged work: fork from that task branch or from develop and state the dependency in the merge request - or wait for the predecessor to land.

## Invariants — directions and sync

- The task flow is one-directional - toward main: a task merges into develop freely (integration without a gate) and enters its gate via a merge request; promotion never sources from develop.
- develop is a dead end: its inputs are task merges and syncs from main, its outputs are none.
- main syncs into develop after every promotion into main - a one-time hygiene operation, not a pipeline step; a gate branch whose content is fully promoted may be reset to main instead of merged - the tooling resets such gates during the seal; stabilization commits of a long-lived release/x.y may sync into develop directly, without waiting for the release to land.

## Invariants — hotfix

- Delivery: the hotfix branch forks from main and targets main via a merge request - bypassing the queue; pre-production verification deploys the hotfix branch itself to the stage environment (a CI branch deploy), not a merge into the queue.
- Propagation - the back-merge, immediately after the merge into main: main -> staging (variant #4) or main -> release/x.y (variant #5, when the train is active); main -> develop always.
- The propagation is mandatory, not optional hygiene: the queue branches are fork bases - without the fix new tasks build against the bug, and the stage environment keeps reproducing it.
- A bug found in unsold code - on stage, in the queue, in an active release - is not a hotfix: it is a regular task into the current gate.
- Variant #3 has no separate hotfix concept - no queue exists, the fix is a regular task through the main gate.

## The variant contracts

- #1 Direct to Main Flow (Trunk-Based Development): working copy -> commit (the CHANGELOG section rides the commit, the gated tag is the stamp) -> main -> prod; a linear history, CI green on every commit.
- #2 Free Merge to Main Flow (GitHub Flow): branch-task (fork: main) -> squash merge + fragment -> main; the seal on main assembles, stamps and tags; main -> prod.
- #3 Reviewed Merge to Main Flow (Git Flow Lite): branch-task (fork: main) -> free merge -> develop; branch-task -> MR (squash) + fragment -> main; the seal on main; main -> sync -> develop; develop deploys to the develop environment, main to production.
- #4 Reviewed Merge to Staging to Main Flow (GitLab Flow Lite): branch-task (fork: staging) -> free merge -> develop; branch-task -> MR (squash) -> staging; staging -> promotion MR (squash, the fragments ride unconsumed) -> main; the seal on main assembles, stamps, tags and syncs/resets the gates; develop -> develop environment, staging -> stage, main -> production.
- #5 Reviewed Merge to Release to Main Flow (Git Flow): branch-task (fork: release/x.y) -> free merge -> develop; branch-task -> MR (squash) -> release/x.y; the train -> release MR (squash, the fragments ride unconsumed) -> main; the seal stamps x.y.0, syncs the gates and bumps the shipped train (release/x.y -> release/x.y+1); the train is singular in the tooling - several manual trains remain an escape hatch; a task slipping to the next train moves by cherry-pick or a repeated merge request.
- Naming deviations from the canons: "Lite" marks the trimmed canon - #3 promotes per-task merge requests instead of develop batches, #4 inverts the canonical direction (staging is the acceptance queue feeding main, not a downstream deploy target) and uses one environment branch instead of the staging-plus-production pair; #5 assembles the release by task merge requests instead of cutting it from develop as a snapshot, with merge requests as gates.

## Versioning — tags as the version truth

- The version truth is the tag on main: the last committed version is read as `git describe --tags --abbrev=0` on the main tip - never from .version or CHANGELOG.md; .version and CHANGELOG.md are generated artifacts of the stamp.
- The granularity: variants #1-#4 - version-per-merge, every entry into main stamps the next version; variant #5 - version-per-release, entering main stamps x.y.0 and a hotfix stamps x.y.z+1.
- The stamp protocol after the entry into main: sync main on the last tip, read the last tag, compute the next semver (the .version line 2 intent when declared and valid, otherwise the patch bump of the tag), land the stamp commit on main - assemble the CHANGELOG section from the fragments, remove them, regenerate .version - and push atomically: `git push --atomic origin main "$NEXT"`; a duplicate-tag rejection means someone stamped first: re-read, recompute, re-stamp; the tag confirmation defaults to deferral in all variants - tagging is always an explicit act.
- The assembly location: #1 - the commit is the stamp; #2-#5 - the fragments ride the merge requests (in #4-#5 through the gate unconsumed) and the seal is the stamp commit on main right after the entry; main carries raw fragments only in the interim between the promotion and the stamp, and the gate sync resets the fully promoted gates clean.
- The stamp commit message: `$NEXT: <Type>: <main message>` - the version first, the type and the main message from the most significant fragment; merge commits and promotion squash titles carry no version prefix - the version arrives with the stamp commit that follows.
- The release actor is a human or an agent: the one who performs the entry into main also performs the stamp.

## Versioning — fragments

- A task branch carries its change record as `.git_flow/changelog_fragments/<UTLBL>.<type>.md`: one English line without the leading `- `; the type is one of added, changed, fixed, deprecated, removed, security.
- The lifecycle: created in the task worktree with the work, rides the merge request into the gate (in #4-#5 further into main with the promotion, unconsumed), consumed by the seal on main - the section is assembled and the file is deleted.
- The free merge into develop carries a fragment copy; the standing main -> develop sync carries the removal; no task forks from develop, so nothing is assembled twice.
- Variant #1 has no fragments - the solo actor writes the CHANGELOG section in the commit itself.

## The repository marker

- A repository declares its variant by exactly one marker file - `.git_flow/.git-flow-<variant>`, committed, copied as-is from the standard's assets; the five names are exhaustive: `.git-flow-direct-to-main-flow`, `.git-flow-free-merge-to-main-flow`, `.git-flow-reviewed-merge-to-main-flow`, `.git-flow-reviewed-merge-to-staging-to-main-flow`, `.git-flow-reviewed-merge-to-release-to-main-flow`.
- The marker content is the declaration, the standard link and the rules list: a `Flow:` line, a `Standard:` line, then `Rules:` followed by one URL per line - every rule of the standard that governs the variant, no others (the variant rule first, then the fork point, the directions and sync, the hotfix where applicable, then the versioning rules).
- More than one marker is a violation - detected by globbing `.git_flow/.git-flow-*`.
- The marker is created when the variant is chosen - scaffolded at project initialization - and updated by the very commit that migrates to another variant.
- During an audit I read the marker first and check the declared variant against the actual branch structure - a divergence is an audit finding; agents read the marker as the input and never guess the flow from the commit history.

## Boundaries

- The team's reality wins over the ladder defaults: proposing a smaller variant for a bigger team is a discussion, never a silent decision.
- The repository is the concrete authority: an existing branching model is audited against the ladder before any change is proposed.
