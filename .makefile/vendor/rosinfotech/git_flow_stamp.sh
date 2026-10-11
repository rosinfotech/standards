#!/bin/bash

LIB_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$LIB_DIR/flow_lib.sh"

flowStamp() {

    local variant branch mode next old recompute attempt train
    local variant_sync=""

    variant=$(flowRequireFlow) || exit 1
    flowRequireVariant "$variant" "2 3 4 5" \
        "variant #1 stamps via make git_flow_commit_push (the commit is the stamp)"

    branch=$(flowCurrentBranch)
    if [ "$branch" != "$FLOW_MAIN_BRANCH" ]; then
        main_worktree=$(flowMainWorktree)
        if [ -n "$(git -C "$main_worktree" status --porcelain)" ]; then
            cliError "the repository worktree is dirty - commit or stash before stamping"
            cliHint "git -C $main_worktree status"
            exit 1
        fi
        git -C "$main_worktree" checkout "$FLOW_MAIN_BRANCH" >/dev/null 2>&1 || {
            cliError "failed to switch the repository worktree to $FLOW_MAIN_BRANCH"
            exit 1
        }
        cd "$main_worktree"
        cliInfo "switched the repository worktree to $FLOW_MAIN_BRANCH"
        printf '\n'
    fi

    flowRequireCleanTree || exit 1

    if flowHasRemote; then
        git fetch origin >/dev/null 2>&1 || true
        if git show-ref --verify --quiet "refs/remotes/origin/$FLOW_MAIN_BRANCH" 2>/dev/null; then
            git merge --ff-only "origin/$FLOW_MAIN_BRANCH" >/dev/null 2>&1 || {
                cliError "$FLOW_MAIN_BRANCH diverged from origin/$FLOW_MAIN_BRANCH - rebase manually"
                exit 1
            }
        fi
    fi

    if [ -n "$(flowFragmentList)" ]; then
        mode="assemble"
        if ! flowReleaseGate; then
            cliInfo "stamp deferred - the fragments accumulate into the next version"
            cliHint "answer y at the gate or set FLOW_RELEASE=1 to tag"
            printf '\n'
            exit 0
        fi
        next=$(getVersion) || exit 1
        flowAssembleSection "$next"
        if [ -z "$FLOW_SECTION_MSG" ]; then
            rm -f "$FLOW_SECTION_FILE"
            cliError "the fragments are empty"
            exit 1
        fi
        flowInsertChangelogSection "$FLOW_SECTION_FILE"
        rm -f "$FLOW_SECTION_FILE"
        rm -f "$FLOW_FRAGMENTS_DIR"/*.md
        flowUpdateVersionArtifact "$next"
        old=$(flowLatestTag "origin/$FLOW_MAIN_BRANCH")
        if flowSubstituteVersion "$old" "$next"; then
            if ! flowConfirm "Continue with the stamp?"; then
                flowDeclined
            fi
        fi
        git add .
        git commit -m "$next: $FLOW_SECTION_TYPE: $FLOW_SECTION_MSG" >/dev/null 2>&1 || {
            cliError "failed to create the stamp commit"
            exit 1
        }
    else
        mode="preassembled"
        next=$(sed -n '1p' .version | tr -d '\n\r' 2>/dev/null)
        if ! flowIsSemver "$next"; then
            cliError "no fragments and no .version artifact - nothing to stamp"
            exit 1
        fi
        old=$(flowLatestTag "origin/$FLOW_MAIN_BRANCH")
        if [ "$old" = "$next" ]; then
            cliInfo "already stamped: $next - syncing the branches"
            variant_sync=1
        elif [ "$variant" -le 3 ]; then
            cliError "no changelog fragments on $FLOW_MAIN_BRANCH - nothing to stamp"
            exit 1
        fi
    fi

    if [ -z "$variant_sync" ]; then

    if [ "$mode" = "preassembled" ] && ! flowReleaseGate; then
        cliInfo "tagging deferred - the promotion stays untagged"
        cliHint "rerun make git_flow_stamp and answer y to tag"
        printf '\n'
        exit 0
    fi

    attempt=0
    while :; do
        attempt=$((attempt + 1))

        if [ "$attempt" -eq 1 ]; then
            if git rev-parse "$next" >/dev/null 2>&1; then
                cliError "tag $next already exists"
                exit 1
            fi
        else
            git tag -d "$next" >/dev/null 2>&1
        fi

        git tag "$next" >/dev/null 2>&1 || {
            cliError "failed to create the tag $next"
            exit 1
        }

        if ! flowHasRemote; then
            cliSuccess "stamped $next (local tag, no remote to push)"
            break
        fi

        if git show-ref --verify --quiet "refs/remotes/origin/$FLOW_MAIN_BRANCH" 2>/dev/null; then
            git push --atomic origin "$FLOW_MAIN_BRANCH" "refs/tags/$next" >/dev/null 2>&1 && break
        else
            git push --atomic --set-upstream origin "$FLOW_MAIN_BRANCH" "refs/tags/$next" >/dev/null 2>&1 && break
        fi

        git fetch origin --tags >/dev/null 2>&1

        recompute=$(flowNextVersion "origin/$FLOW_MAIN_BRANCH")

        if [ "$recompute" = "$next" ] || [ "$attempt" -ge 3 ]; then
            cliError "failed to push $FLOW_MAIN_BRANCH and the tag $next"
            exit 1
        fi

        cliWarning "tag $next was taken concurrently - re-stamping as $recompute"
        sed -i '' "s|^## \[$next\]|## [$recompute]|" CHANGELOG.md
        flowUpdateVersionArtifact "$recompute"
        flowSubstituteVersion "$next" "$recompute" >/dev/null
        git add .
        if [ "$mode" = "assemble" ]; then
            git commit --amend -m "$recompute: $FLOW_SECTION_TYPE: $FLOW_SECTION_MSG" >/dev/null 2>&1
        else
            git commit -m "$recompute: Changed: Version re-stamp after a concurrent entry" >/dev/null 2>&1
        fi
        next="$recompute"
    done
    fi

    if [ -z "$variant_sync" ]; then
        if flowHasRemote; then
            cliSuccess "stamped $next (tag pushed atomically with $FLOW_MAIN_BRANCH)"
            if [ "$variant" -ge 3 ]; then
                printf '\n'
            fi
        fi
    else
        printf '\n'
    fi

    case "$variant" in
        3)
            flowUpdateBranchFromMain develop
            ;;
        4)
            flowUpdateBranchFromMain develop
            if [ "$mode" = "assemble" ]; then
                flowUpdateBranchFromMain staging
            fi
            ;;
        5)
            flowUpdateBranchFromMain develop
            if [ "$mode" = "assemble" ]; then
                for train in $(git for-each-ref --format='%(refname:short)' 'refs/heads/release/*'); do
                    flowUpdateBranchFromMain "$train"
                done
            fi
            ;;
    esac

    flowCleanupMergedBranches

}

cliFrameInit
flowStamp "$@"
