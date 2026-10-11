#!/bin/bash

LIB_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$LIB_DIR/flow_lib.sh"

flowBranchState() {
    local branch="$1" state=""
    git show-ref --verify --quiet "refs/heads/$branch" 2>/dev/null && state="local"
    git show-ref --verify --quiet "refs/remotes/origin/$branch" 2>/dev/null && \
        state="$state${state:++}remote"
    [ -n "$state" ] || state="missing"
    echo "$state"
}

flowStatus() {

    local variant name marker info branch train tag artifact findings=0
    local line1 line2 floor

    flowRequireGitRepo

    if ! marker=$(flowMarkerPath); then
        cliInfo "flow not declared"
        cliHint "make git_flow_init <number>"
        exit 0
    fi

    info=$(flowMarkerInfo "$marker")
    if [ -z "$info" ]; then
        cliError "malformed flow file $marker (no 'Flow: Variant #N' line)"
        exit 1
    fi
    variant="${info%%|*}"
    name="${info#*|}"

    cliHeader3 "Flow"
    printf '\n'
    printf -- '- variant: #%s - %s;\n' "$variant" "$name"
    printf -- '- flow file: %s;\n' "$marker"
    printf '\n'

    cliHeader3 "Branches"
    printf '\n'
    printf -- '- %s: %s;\n' "$FLOW_MAIN_BRANCH" "$(flowBranchState "$FLOW_MAIN_BRANCH")"
    [ "$variant" -ge 3 ] && printf -- '- develop: %s;\n' "$(flowBranchState develop)"
    [ "$variant" -eq 4 ] && printf -- '- staging: %s;\n' "$(flowBranchState staging)"
    if [ "$variant" -eq 5 ]; then
        for train in $(git for-each-ref --format='%(refname:short)' 'refs/heads/release/*'); do
            printf -- '- %s: %s;\n' "$train" "$(flowBranchState "$train")"
        done
    fi
    printf '\n'

    cliHeader3 "Version"
    printf '\n'
    tag=$(flowLatestTag "$FLOW_MAIN_BRANCH" 2>/dev/null)
    [ -z "$tag" ] && flowHasRemote && tag=$(flowLatestTag "origin/$FLOW_MAIN_BRANCH" 2>/dev/null)
    printf -- '- tag (version truth): %s;\n' "${tag:-none}"
    if [ -n "$tag" ] && flowIsSemver "$tag"; then
        floor=$(flowBumpPatch "$tag")
        printf -- '- default next stamp (patch): %s;\n' "$floor"
    fi
    if [ -f .version ]; then
        line1=$(sed -n '1p' .version | tr -d '\n\r')
        line2=$(sed -n '2p' .version | tr -d '\n\r')
        printf -- '- .version line 1 (current): %s, line 2 (future): %s;\n' \
            "${line1:-?}" "${line2:-?}"
    fi
    printf '\n'

    if [ -n "$(flowFragmentList)" ]; then
        cliHeader3 "Fragments"
        printf '\n'
        for branch in $(flowFragmentList); do
            printf -- '- %s;\n' "$branch"
        done
        cliHint "make git_flow_stamp with FLOW_RELEASE=1 tags them (the default defers)"
        printf '\n'
    fi

    if [ "$variant" -ge 3 ] && [ "$(flowBranchState develop)" = "missing" ]; then
        printf -- '- finding: develop is missing (run make git_flow_init %s to create it);\n' "$variant"
        findings=$((findings + 1))
    fi
    if [ "$variant" -eq 4 ] && [ "$(flowBranchState staging)" = "missing" ]; then
        printf -- '- finding: staging is missing (run make git_flow_init 4 to create it);\n'
        findings=$((findings + 1))
    fi
    if [ "$variant" -eq 5 ] && [ -z "$(flowCurrentTrain)" ]; then
        printf -- '- finding: no active release/x.y train (run make git_flow_init 5 to create one);\n'
        findings=$((findings + 1))
    fi
    if [ "$variant" -le 2 ] && [ "$(flowBranchState staging)" != "missing" ]; then
        printf -- '- finding: staging exists but variant #%s does not use it;\n' "$variant"
        findings=$((findings + 1))
    fi
    [ "$findings" -gt 0 ] && printf '\n'

    cliHeader3 "Commands"
    printf '\n'
    case "$variant" in
        1)
            printf -- '- git_flow_commit_push: enabled (the commit is the stamp);\n'
            printf -- '- git_task_*: blocked (variant #1 has no task branches);\n'
            printf -- '- git_flow_hotfix_start: blocked (a production fix is a regular commit);\n'
            printf -- '- git_flow_prepare_release: blocked (no gate branches);\n'
            printf -- '- git_flow_stamp: blocked (git_flow_commit_push is the stamp);\n'
            ;;
        2)
            printf -- '- git_flow_task_start: enabled (fork: %s);\n' "$FLOW_MAIN_BRANCH"
            printf -- '- git_flow_task_fragment: enabled;\n'
            printf -- '- git_flow_task_finish: enabled (free merge into %s);\n' "$FLOW_MAIN_BRANCH"
            printf -- '- git_flow_stamp: enabled (after the merge);\n'
            printf -- '- git_flow_task_dev_merge: blocked (variant #2 has no develop line);\n'
            printf -- '- git_flow_hotfix_start: blocked (a hotfix is a regular task branch);\n'
            printf -- '- git_flow_prepare_release: blocked (the stamp assembles on main);\n'
            ;;
        3)
            printf -- '- git_flow_task_start: enabled (fork: %s);\n' "$FLOW_MAIN_BRANCH"
            printf -- '- git_flow_task_fragment: enabled;\n'
            printf -- '- git_flow_task_dev_merge: enabled (free merge into develop);\n'
            printf -- '- git_flow_task_finish: enabled (MR into %s);\n' "$FLOW_MAIN_BRANCH"
            printf -- '- git_flow_stamp: enabled (after the MR merge);\n'
            printf -- '- git_flow_hotfix_start: blocked (no queue - a fix is a regular task);\n'
            printf -- '- git_flow_prepare_release: blocked (the stamp assembles on main);\n'
            ;;
        4)
            printf -- '- git_flow_task_start: enabled (fork: staging);\n'
            printf -- '- git_flow_task_fragment: enabled;\n'
            printf -- '- git_flow_task_dev_merge: enabled (free merge into develop);\n'
            printf -- '- git_flow_task_finish: enabled (MR into staging);\n'
            printf -- '- git_flow_hotfix_start: enabled (fork: main, bypasses the queue);\n'
            printf -- '- git_flow_prepare_release: enabled (on staging);\n'
            printf -- '- git_flow_stamp: enabled (after the promotion / hotfix merge);\n'
            ;;
        5)
            printf -- '- git_flow_task_start: enabled (fork: release/x.y);\n'
            printf -- '- git_flow_task_fragment: enabled;\n'
            printf -- '- git_flow_task_dev_merge: enabled (free merge into develop);\n'
            printf -- '- git_flow_task_finish: enabled (MR into release/x.y);\n'
            printf -- '- git_flow_hotfix_start: enabled (fork: main, bypasses the queue);\n'
            printf -- '- git_flow_prepare_release: enabled (on release/x.y);\n'
            printf -- '- git_flow_stamp: enabled (after the release / hotfix merge);\n'
            ;;
        *)
            printf -- '- commands: unknown variant #%s - see the standard;\n' "$variant"
            ;;
    esac
    printf '\n'

    cliHeader3 "Rules"
    printf '\n'
    sed -n 's/^- //p' "$marker" 2>/dev/null | while read -r branch; do
        printf -- '- '
        cliPath "$branch"
        printf ';\n'
    done

}

cliFrameInit
flowStatus "$@"
