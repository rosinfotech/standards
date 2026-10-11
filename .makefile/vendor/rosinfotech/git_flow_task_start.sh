#!/bin/bash

LIB_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$LIB_DIR/flow_lib.sh"

flowTaskStart() {

    local label="$1" variant base base_ref branch worktree utlbl

    variant=$(flowRequireFlow) || exit 1
    flowRequireVariant "$variant" "2 3 4 5" \
        "variant #1 commits directly into main (make git_flow_commit_push)"

    if [ -z "$label" ]; then
        cliError "the task label is required"
        cliHint "make git_flow_task_start <label>"
        exit 2
    fi

    label=$(echo "$label" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g; s/^-*//; s/-*$//')

    if [ -z "$label" ]; then
        cliError "the label must contain letters or digits"
        exit 2
    fi

    base=$(flowForkBase "$variant") || exit 1

    if flowHasRemote; then
        git fetch origin >/dev/null 2>&1 || true
    fi

    base_ref=$(flowRemoteBaseRef "$base")

    if ! git rev-parse --verify --quiet "$base_ref^{commit}" >/dev/null 2>&1; then
        cliError "fork base '$base_ref' does not exist"
        exit 1
    fi

    utlbl=$(date +%y%m%d%H%M)
    branch="task-${utlbl}-${label}"
    worktree="../$(basename "$PWD")-${branch}"

    if git show-ref --verify --quiet "refs/heads/$branch" 2>/dev/null; then
        cliError "branch $branch already exists"
        exit 1
    fi

    if [ -e "$worktree" ]; then
        cliError "worktree path already exists: $worktree"
        exit 1
    fi

    git worktree add -b "$branch" "$worktree" "$base_ref" >/dev/null 2>&1 || {
        cliError "failed to create the worktree $worktree"
        exit 1
    }

    cliSuccess "task branch $branch created (fork: $base_ref)"
    printf '\n'
    printf -- '- worktree: %s;\n' "$worktree"
    printf '\n'
    cliHeader3 "Next steps"
    printf '\n'
    printf '1. cd %s;\n' "$worktree"
    printf '2. make git_flow_task_fragment "Added: one English line";\n'
    printf '3. make git_flow_task_dev_merge (variants #3-#5);\n'

}

cliFrameInit
flowTaskStart "$@"
