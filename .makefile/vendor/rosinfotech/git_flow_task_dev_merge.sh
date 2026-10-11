#!/bin/bash

LIB_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$LIB_DIR/flow_lib.sh"

flowTaskIntegrate() {

    local variant branch worktree base reason

    variant=$(flowRequireFlow) || exit 1

    reason=""
    case "$variant" in
        1) reason="variant #1 commits directly into main" ;;
        2) reason="variant #2 merges the task into main directly (git_flow_task_finish)" ;;
    esac
    flowRequireVariant "$variant" "3 4 5" "$reason"

    branch=$(flowCurrentBranch)
    case "$branch" in
        task-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-*)
            ;;
        hotfix-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-*)
            cliError "hotfix branches bypass develop (rule #2610082120)"
            exit 1
            ;;
        *)
            cliError "not on a task branch (current: ${branch:-none})"
            exit 1
            ;;
    esac

    flowRequireCleanTree || exit 1

    if git show-ref --verify --quiet "refs/remotes/origin/dev" 2>/dev/null && \
        flowBranchPatchesIn "$branch" "develop"; then
        cliError "$branch is already integrated into origin/develop - nothing to integrate"
        exit 1
    fi

    if flowHasRemote; then
        git fetch origin >/dev/null 2>&1 || true
    fi

    if ! git show-ref --verify --quiet "refs/heads/dev" 2>/dev/null; then
        base=$(flowRemoteBaseRef "$FLOW_MAIN_BRANCH")
        git branch develop "$base"
        cliInfo "branch created: develop (from $base)"
        printf '\n'
        flowHasRemote && git push -u origin dev >/dev/null 2>&1
    fi

    worktree=$(flowBranchWorktree develop)
    current_physical="$(cd . && pwd -P)"

    if [ -n "$worktree" ] && [ "$worktree" != "$current_physical" ]; then
        if [ -n "$(git -C "$worktree" status --porcelain)" ]; then
            cliError "develop is checked out dirty in $worktree - commit or stash there first"
            exit 1
        fi
        git -C "$worktree" merge --no-edit "$branch" >/dev/null 2>&1 || {
            cliError "conflict merging $branch into develop - resolve in $worktree"
            exit 1
        }
        git -C "$worktree" push origin dev >/dev/null 2>&1 || {
            cliError "failed to push develop"
            exit 1
        }
    else
        git checkout dev >/dev/null 2>&1 || exit 1
        git merge --no-edit "$branch" >/dev/null 2>&1 || {
            cliError "conflict merging $branch into develop - resolve manually"
            exit 1
        }
        git push origin dev >/dev/null 2>&1 || {
            cliError "failed to push develop"
            exit 1
        }
        git checkout "$branch" >/dev/null 2>&1
    fi

    cliSuccess "integrated: $branch -> develop (free merge, no gate)"
    cliHint "finish with: make git_flow_task_finish"

}

cliFrameInit
flowTaskIntegrate "$@"
