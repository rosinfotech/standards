#!/bin/bash

LIB_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$LIB_DIR/flow_lib.sh"

flowHotfixFinish() {

    local variant branch reason

    variant=$(flowRequireFlow) || exit 1

    reason=""
    case "$variant" in
        1) reason="a production fix is a regular commit (make git_flow_commit_push)" ;;
        2) reason="a hotfix is a regular task branch (make git_flow_task_start)" ;;
        3) reason="there is no queue to bypass - a fix is a regular task (make git_flow_task_start)" ;;
    esac
    flowRequireVariant "$variant" "4 5" "$reason"

    branch=$(flowCurrentBranch)
    case "$branch" in
        hotfix-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-*)
            ;;
        task-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-*)
            cliError "a task branch finishes with make git_flow_task_finish"
            exit 1
            ;;
        *)
            cliError "not on a hotfix branch (current: ${branch:-none})"
            exit 1
            ;;
    esac

    flowRequireCleanTree || exit 1

    if flowBranchPatchesIn "$branch" "$FLOW_MAIN_BRANCH"; then
        cliError "the hotfix is already in $FLOW_MAIN_BRANCH - nothing to finish"
        cliHint "run make git_flow_stamp on $FLOW_MAIN_BRANCH after the merge"
        exit 1
    fi

    if flowHasRemote; then
        git fetch origin >/dev/null 2>&1 || true
    fi

    git push -u origin "$branch" >/dev/null 2>&1 || {
        cliError "failed to push $branch"
        exit 1
    }

    cliSuccess "pushed: $branch"
    printf '\n'
    printf -- '- merge request: %s -> %s (bypasses the queue);\n' "$branch" "$FLOW_MAIN_BRANCH"
    flowMergeRequestUrl "$branch" "$FLOW_MAIN_BRANCH"
    printf '\n'
    cliHint "enable squash in the merge request (the title carries no version - the hotfix stamp follows)"
    cliHint "after the merge: make git_flow_stamp (it switches to main and back-merges everywhere)"

}

cliFrameInit
flowHotfixFinish "$@"
