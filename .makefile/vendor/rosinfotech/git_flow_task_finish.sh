#!/bin/bash

LIB_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$LIB_DIR/flow_lib.sh"

flowTaskFinish() {

    local variant branch target worktree current_physical main_worktree

    variant=$(flowRequireFlow) || exit 1
    flowRequireVariant "$variant" "2 3 4 5" \
        "variant #1 commits directly into main (make git_flow_commit_push)"

    branch=$(flowCurrentBranch)
    case "$branch" in
        task-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-*)
            ;;
        hotfix-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-*)
            cliError "a hotfix merges via its own MR into main (see git_flow_hotfix_start output)"
            exit 1
            ;;
        *)
            cliError "not on a task branch (current: ${branch:-none})"
            exit 1
            ;;
    esac

    flowRequireCleanTree || exit 1

    if flowBranchPatchesIn "$branch" "$(flowForkBase "$variant" 2>/dev/null || echo "$FLOW_MAIN_BRANCH")"; then
        cliError "the task is already in its merge-request target - nothing to finish"
        cliHint "run make git_flow_stamp on $FLOW_MAIN_BRANCH after the merge"
        exit 1
    fi

    if flowHasRemote; then
        git fetch origin >/dev/null 2>&1 || true
    fi

    if [ "$variant" -eq 2 ]; then
        senior=$(flowSeniorFragment) || {
            cliError "the task carries no changelog fragment - add one before finishing"
            cliHint "make git_flow_task_fragment \"Added: one English line\""
            exit 1
        }
        current_physical="$(cd . && pwd -P)"
        main_worktree=$(flowBranchWorktree "$FLOW_MAIN_BRANCH")

        if [ -n "$main_worktree" ] && [ "$main_worktree" != "$current_physical" ]; then
            if [ -n "$(git -C "$main_worktree" status --porcelain)" ]; then
                cliError "main is checked out dirty in $main_worktree - commit or stash there first"
                exit 1
            fi
            git -C "$main_worktree" merge --ff-only "origin/$FLOW_MAIN_BRANCH" >/dev/null 2>&1
            git -C "$main_worktree" merge --squash "$branch" >/dev/null 2>&1 || {
                cliError "conflict merging $branch into main - resolve in $main_worktree"
                exit 1
            }
            git -C "$main_worktree" commit -m "$senior" >/dev/null 2>&1 || {
                cliError "failed to create the squash commit in $main_worktree"
                exit 1
            }
            git -C "$main_worktree" push origin "$FLOW_MAIN_BRANCH" >/dev/null 2>&1 || {
                cliError "failed to push main"
                exit 1
            }
        else
            git checkout "$FLOW_MAIN_BRANCH" >/dev/null 2>&1 || exit 1
            git merge --ff-only "origin/$FLOW_MAIN_BRANCH" >/dev/null 2>&1
            git merge --squash "$branch" >/dev/null 2>&1 || {
                cliError "conflict merging $branch into main - resolve manually"
                exit 1
            }
            git commit -m "$senior" >/dev/null 2>&1 || {
                cliError "failed to create the squash commit"
                exit 1
            }
            git push origin "$FLOW_MAIN_BRANCH" >/dev/null 2>&1 || {
                cliError "failed to push main"
                exit 1
            }
            git checkout "$branch" >/dev/null 2>&1
        fi

        cliSuccess "task entered main as one commit: $senior"
        cliHint "stamp the version: make git_flow_stamp (it switches to main itself)"
        return 0
    fi

    target=$(flowForkBase "$variant") || exit 1

    git push -u origin "$branch" >/dev/null 2>&1 || {
        cliError "failed to push $branch"
        exit 1
    }

    cliSuccess "pushed: $branch"
    printf '\n'
    printf -- '- merge request: %s -> %s;\n' "$branch" "$target"
    flowMergeRequestUrl "$branch" "$target"
    printf '\n'
    cliHint "integrate into develop first when not done yet: make git_flow_task_dev_merge"
    if [ "$variant" -ge 4 ]; then
        cliHint "after the MR merge: make git_flow_prepare_release (on $target)"
    else
        cliHint "after the MR merge: make git_flow_stamp (on $FLOW_MAIN_BRANCH)"
    fi

}

cliFrameInit
flowTaskFinish "$@"
