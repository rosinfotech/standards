#!/bin/bash
#
# flow_lib.sh - the shared machinery of the Git Flow Standard commands
# (github.com/rosinfotech/standards#the-git-flow-standard). A library, not a
# command: sourced by git_flow_*.sh, git_task_*.sh, git_flow_hotfix_start.sh.
#
# The variant matrix (the fork point equals the merge-request target,
# rule #2610082116):
#   #1 Trunk-Based Development - no branches, commits land in main directly
#   #2 GitHub Flow             - fork main, free merge into main
#   #3 Git Flow Lite           - fork main, MR into main, free merge into develop
#   #4 GitLab Flow Lite        - fork staging, MR into staging, promotion to main
#   #5 Git Flow                - fork release/x.y, MR into the train, release to main

FLOW_MAIN_BRANCH="main"
FLOW_DEV_BRANCH="develop"
FLOW_DIR=".git_flow"
FLOW_MARKER_PREFIX=".git-flow-"
FLOW_LEGACY_PREFIX=".github-com-rosinfotech-"
FLOW_FRAGMENTS_DIR=".git_flow/changelog_fragments"
FLOW_TYPE_ORDER="added changed fixed deprecated removed security"
FLOW_STANDARD_API="${FLOW_STANDARD_API:-https://api.github.com/repos/rosinfotech/standards/contents/standards/git-flow-standard/assets}"
FLOW_STANDARD_RAW="${FLOW_STANDARD_RAW:-https://raw.githubusercontent.com/rosinfotech/standards/master/standards/git-flow-standard/assets}"

[ -n "$LIB_DIR" ] && [ -f "$LIB_DIR/version_get.sh" ] && source "$LIB_DIR/version_get.sh"
[ -n "$LIB_DIR" ] && [ -f "$LIB_DIR/cli_lib.sh" ] && source "$LIB_DIR/cli_lib.sh"

flowMarkerInfo() { # marker file -> "number|name" from its Flow line
    sed -n 's/^Flow: Variant #\([0-9][0-9]*\) - \(.*\)$/\1|\2/p' "$1" 2>/dev/null | head -n 1
}

flowMarkerPath() { # prints the regulating file: .git_flow/.git-flow-*, legacy root marker, or empty
    local marker
    for marker in "$FLOW_DIR"/"$FLOW_MARKER_PREFIX"*; do
        [ -e "$marker" ] && { echo "$marker"; return 0; }
    done
    for marker in ${FLOW_LEGACY_PREFIX}*; do
        [ -e "$marker" ] && { echo "$marker"; return 0; }
    done
    return 1
}

flowVariantLabel() { # number -> the declared variant name (the repo flow file, no network)
    local info
    if info=$(flowMarkerInfo "$(flowMarkerPath)" 2>/dev/null); then
        if [ "${info%%|*}" = "$1" ]; then
            echo "${info#*|}"
            return 0
        fi
    fi
    echo "Variant #$1"
}

flowRequireHttp() {
    command -v curl >/dev/null 2>&1 || {
        cliError "curl is required to fetch the standard assets"
        return 1
    }
}

flowStandardCatalog() { # prints "number<TAB>name<TAB>asset" per marker asset of the standard
    local listing asset info
    flowRequireHttp || return 1
    listing=$(curl -fsSL --max-time 20 "$FLOW_STANDARD_API") || {
        cliError "cannot fetch the assets listing from the standards repository"
        cliHint "$FLOW_STANDARD_API"
        return 1
    }
    for asset in $(printf '%s' "$listing" \
        | sed -n 's/.*"name": *"\('"$FLOW_MARKER_PREFIX"'[a-z0-9-]*\)".*/\1/p' | sort -u); do
        info=$(curl -fsSL --max-time 20 "$FLOW_STANDARD_RAW/$asset" \
            | sed -n 's/^Flow: Variant #\([0-9][0-9]*\) - \(.*\)$/\1|\2/p' | head -n 1)
        [ -z "$info" ] && continue
        printf '%s\t%s\t%s\n' "${info%%|*}" "${info#*|}" "$asset"
    done
}

flowFetchMarkerAsset() { # asset name dest -> writes the marker content as-is
    flowRequireHttp || return 1
    curl -fsSL --max-time 20 "$FLOW_STANDARD_RAW/$1" -o "$2" || {
        cliError "cannot fetch the marker asset $1"
        cliHint "$FLOW_STANDARD_RAW/$1"
        rm -f "$2"
        return 1
    }
}

flowTypeTitle() {
    echo "$1" | awk '{ print toupper(substr($0, 1, 1)) substr($0, 2) }'
}

flowRequireGitRepo() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
        cliError "not a git repository"
        exit 1
    }
}

flowDetectVariant() {
    local marker info
    marker=$(flowMarkerPath) || return 1
    info=$(flowMarkerInfo "$marker")
    if [ -z "$info" ]; then
        cliError "malformed flow file $marker (no 'Flow: Variant #N' line)"
        exit 1
    fi
    echo "${info%%|*}"
}

flowRequireFlow() {
    flowRequireGitRepo
    local variant
    variant=$(flowDetectVariant)
    if [ -z "$variant" ]; then
        cliError "no flow declared (.git_flow/.git-flow-* missing) - declare the variant first"
        cliHint "make git_flow_init <number>"
        exit 1
    fi
    echo "$variant"
}

flowRequireVariant() {
    local variant="$1" allowed="$2" reason="$3"
    case " $allowed " in
        *" $variant "*) return 0 ;;
    esac
    cliError "$(flowVariantLabel "$variant") does not use this command - $reason"
    exit 1
}

flowHasRemote() {
    git remote | grep -q .
}

flowRemoteBaseRef() {
    if git show-ref --verify --quiet "refs/remotes/origin/$1" 2>/dev/null; then
        echo "origin/$1"
    else
        echo "$1"
    fi
}

flowCurrentBranch() {
    git symbolic-ref --short HEAD 2>/dev/null
}

flowCurrentTrain() {
    local train
    train=$(git for-each-ref --sort=committerdate --format='%(refname:short)' \
        'refs/heads/release/*' | tail -n 1)
    if [ -z "$train" ]; then
        train=$(git for-each-ref --sort=committerdate --format='%(refname:short)' \
            'refs/remotes/origin/release/*' | tail -n 1 | sed 's|^origin/||')
    fi
    [ -n "$train" ] && echo "$train"
}

flowForkBase() {
    case "$1" in
        2|3) echo "$FLOW_MAIN_BRANCH" ;;
        4) echo "staging" ;;
        5)
            flowCurrentTrain || {
                cliError "variant #5 requires an active release/x.y train"
                cliHint "make git_flow_init 5 creates one"
                exit 1
            }
            ;;
    esac
}

flowMainWorktree() {
    git worktree list --porcelain | awk '/^worktree /{ print $2; exit }'
}

flowBranchWorktree() {
    git worktree list --porcelain | awk -v b="refs/heads/$1" '
        $0 == "branch " b { print wt; exit }
        /^worktree / { wt = $2 }
    '
}

flowRequireCleanTree() {
    if [ -n "$(git status --porcelain)" ]; then
        cliError "working tree is not clean - commit or stash first"
        return 1
    fi
}

flowTaskLabelFromBranch() {
    echo "$1" | grep -oE '[0-9]{10}' | head -n 1
}

flowSeniorFragment() { # prints "<Type>: <line>" - the senior fragment of the task (the message source)
    local type fragment line
    for type in $FLOW_TYPE_ORDER; do
        for fragment in "$FLOW_FRAGMENTS_DIR"/*."$type".md; do
            [ -e "$fragment" ] || continue
            line=$(sed '/^[[:space:]]*$/d' "$fragment" | head -n 1)
            if [ -n "$line" ]; then
                echo "$(flowTypeTitle "$type"): $line"
                return 0
            fi
        done
    done
    return 1
}

flowRequireTaskCommitMessage() { # message -> validates "<Type>: <message>" on task/hotfix branches
    local message="$1" branch type rest
    branch=$(flowCurrentBranch)
    case "$branch" in
        task-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-*|\
hotfix-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-*)
            ;;
        *)
            return 0
            ;;
    esac
    type=$(echo "${message%%:*}" | tr '[:upper:]' '[:lower:]' | sed 's/^ *//; s/ *$//')
    rest=$(echo "${message#*:}" | sed 's/^ *//; s/ *$//')
    if ! echo "$FLOW_TYPE_ORDER" | grep -qw "$type" || [ -z "$rest" ]; then
        cliError "task commits follow \"<Type>: <message>\" - got '${message}'"
        cliHint "types: $(echo $FLOW_TYPE_ORDER | sed 's/ /, /g')"
        exit 2
    fi
    return 0
}

flowIsSemver() {
    echo "$1" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'
}

flowLatestTag() {
    git describe --tags --abbrev=0 "$1" 2>/dev/null
}

flowBumpPatch() {
    echo "$1" | awk -F. '{ print $1 "." $2 "." ($3 + 1) }'
}

flowBumpMinorBase() {
    echo "$1" | awk -F. '{ print $1 "." ($2 + 1) }'
}

flowBootstrapVersion() {
    local legacy=""
    [ -f .version ] && legacy=$(sed -n '1p' .version | tr -d '\n\r')
    if flowIsSemver "$legacy"; then
        echo "$legacy"
    else
        echo "0.1.0"
    fi
}

flowNextVersion() {
    local last
    last=$(flowLatestTag "$1")
    if [ -n "$last" ] && flowIsSemver "$last"; then
        flowBumpPatch "$last"
    else
        flowBootstrapVersion
    fi
}

flowFragmentList() {
    local fragment
    for fragment in "$FLOW_FRAGMENTS_DIR"/*.md; do
        [ -e "$fragment" ] && echo "$fragment"
    done
}

flowFragmentListType() {
    local fragment
    for fragment in "$FLOW_FRAGMENTS_DIR"/*."$1".md; do
        [ -e "$fragment" ] && echo "$fragment"
    done
}

flowAssembleSection() {
    local version="$1" type fragment line
    FLOW_SECTION_TYPE=""
    FLOW_SECTION_MSG=""
    FLOW_SECTION_FILE="$(mktemp)"
    echo "## [$version] - $(date +%Y-%m-%d)" > "$FLOW_SECTION_FILE"
    for type in $FLOW_TYPE_ORDER; do
        [ -z "$(flowFragmentListType "$type")" ] && continue
        echo "" >> "$FLOW_SECTION_FILE"
        echo "### $(flowTypeTitle "$type")" >> "$FLOW_SECTION_FILE"
        echo "" >> "$FLOW_SECTION_FILE"
        for fragment in $(flowFragmentListType "$type"); do
            while IFS= read -r line; do
                [ -z "$line" ] && continue
                echo "- $line" >> "$FLOW_SECTION_FILE"
                if [ -z "$FLOW_SECTION_MSG" ]; then
                    FLOW_SECTION_TYPE=$(flowTypeTitle "$type")
                    FLOW_SECTION_MSG="$line"
                fi
            done < "$fragment"
        done
    done
}

flowInsertChangelogSection() {
    local section_file="$1"
    if [ ! -f CHANGELOG.md ] || ! grep -q '^# Changelog$' CHANGELOG.md; then
        {
            echo "<!-- markdownlint-disable MD041 -->"
            echo ""
            echo "# Changelog"
            echo ""
            cat CHANGELOG.md 2>/dev/null
        } > CHANGELOG.md.new
        mv CHANGELOG.md.new CHANGELOG.md
    fi
    awk -v section="$section_file" '
        /^# Changelog$/ && !done {
            print
            print ""
            while ((getline line < section) > 0) {
                print line
            }
            done = 1
            next
        }
        { print }
    ' CHANGELOG.md > CHANGELOG.md.new
    mv CHANGELOG.md.new CHANGELOG.md
}

flowUpdateVersionArtifact() {
    local version="$1" list=""
    [ -f .version ] && list=$(sed -n '3,$p' .version)
    {
        echo "$version"
        echo "$version"
        [ -n "$list" ] && printf '%s\n' "$list"
    } > .version
}

flowVersionTargets() {
    [ -f .version ] || return 0
    sed -n '3,$p' .version
}

flowSubstituteParseEntry() { # entry -> sets FLOW_ENTRY_PATH / FLOW_ENTRY_LINE
    FLOW_ENTRY_PATH="$1"
    FLOW_ENTRY_LINE=""
    case "$1" in
        *:[0-9]*)
            FLOW_ENTRY_PATH="${1%:*}"
            FLOW_ENTRY_LINE="${1##*:}"
            ;;
    esac
}

flowSubstituteScan() { # old -> prints "path:lineno" for every pending replacement
    local old="$1" entry hit
    [ -z "$old" ] && return 0
    while IFS= read -r entry; do
        [ -z "$entry" ] && continue
        flowSubstituteParseEntry "$entry"
        [ -f "$FLOW_ENTRY_PATH" ] || continue
        if [ -n "$FLOW_ENTRY_LINE" ]; then
            sed -n "${FLOW_ENTRY_LINE}p" "$FLOW_ENTRY_PATH" | grep -nw "$old" >/dev/null && \
                echo "${FLOW_ENTRY_PATH}:${FLOW_ENTRY_LINE}"
        else
            grep -nw "$old" "$FLOW_ENTRY_PATH" 2>/dev/null | cut -d: -f1 | while read -r hit; do
                echo "${FLOW_ENTRY_PATH}:${hit}"
            done
        fi
    done <<TARGETS
$(flowVersionTargets)
TARGETS
}

flowSubstituteApply() { # old new
    local old="$1" new="$2" entry
    while IFS= read -r entry; do
        [ -z "$entry" ] && continue
        flowSubstituteParseEntry "$entry"
        [ -f "$FLOW_ENTRY_PATH" ] || continue
        if [ -n "$FLOW_ENTRY_LINE" ]; then
            sed -i '' "${FLOW_ENTRY_LINE}s/[[:<:]]$old[[:>:]]/$new/g" "$FLOW_ENTRY_PATH"
        else
            sed -i '' "s/[[:<:]]$old[[:>:]]/$new/g" "$FLOW_ENTRY_PATH"
        fi
    done <<TARGETS
$(flowVersionTargets)
TARGETS
}

flowConfirm() { # question -> 0 yes, 1 no; FLOW_YES (agents, pipelines) or a non-TTY stream bypasses
    local answer
    case "${FLOW_YES:-}" in
        ''|0|[nN][oO]|[fF][aA][lL][sS][eE]) ;;
        *) return 0 ;;
    esac
    [ -t 0 ] || return 0
    if [ "$CLI_COLOR_ERR" = "1" ]; then
        printf '%s%s [Y/n]: %s' "${CLI_BOLD}${CLI_CYAN}" "$1" "$CLI_RESET" >&2
    else
        printf '%s [Y/n]: ' "$1" >&2
    fi
    if ! read -r answer; then
        return 0
    fi
    case "$answer" in
        ''|[yY]|[yY][eE][sS]) return 0 ;;
        [nN]|[nN][oO]) return 1 ;;
        *)
            cliError "unknown answer '${answer}' - expected Y or n"
            exit 2
            ;;
    esac
}

flowDeclined() {
    cliInfo "declined - the substitution stays in the working tree, nothing committed"
    cliHint "review the files, rerun the command to continue, or revert with: git checkout -- ."
    exit 1
}

flowReleaseGate() { # -> 0 tag now, 1 defer; FLOW_RELEASE forces; the default (incl. a non-TTY stream) defers
    local answer
    case "${FLOW_RELEASE:-}" in
        1|[tT][rR][uU][eE]|[yY][eE][sS]) return 0 ;;
        0|[fF][aA][lL][sS][eE]|[nN][oO]) return 1 ;;
    esac
    [ -t 0 ] || return 1
    if [ "$CLI_COLOR_ERR" = "1" ]; then
        printf '%s%s [y/N]: %s' "${CLI_BOLD}${CLI_CYAN}" "Tag now (the tag may trigger a deploy)?" "$CLI_RESET" >&2
    else
        printf 'Tag now (the tag may trigger a deploy)? [y/N]: ' >&2
    fi
    if ! read -r answer; then
        return 1
    fi
    case "$answer" in
        [yY]|[yY][eE][sS]) return 0 ;;
        ''|[nN]|[nN][oO]) return 1 ;;
        *)
            cliError "unknown answer '${answer}' - expected y or N"
            exit 2
            ;;
    esac
}

flowSubstituteVersion() { # old new - applies the substitution, reports; 0 = substituted, 1 = nothing to do
    local old="$1" new="$2" scan
    [ -z "$old" ] && return 1
    [ "$old" = "$new" ] && return 1
    scan=$(flowSubstituteScan "$old")
    if [ -z "$scan" ]; then
        if [ -n "$(flowVersionTargets)" ]; then
            cliInfo "no occurrences of ${old} in the .version targets - nothing to substitute"
            printf '\n'
        fi
        return 1
    fi
    flowSubstituteApply "$old" "$new"
    cliInfo "version substitution applied (${old} -> ${new}):"
    printf '\n'
    echo "$scan" | sed 's/^/    - /; s/$/;/'
    printf '\n'
    cliInfo "$(echo "$scan" | wc -l | tr -d ' ') location(s) substituted"
    printf '\n'
    return 0
}

flowEnsureBranch() {
    local branch="$1" base="$2"
    if ! git show-ref --verify --quiet "refs/heads/$branch" 2>/dev/null; then
        git branch "$branch" "$base"
        echo "Branch created: $branch (from $base)"
    fi
    if flowHasRemote && ! git show-ref --verify --quiet "refs/remotes/origin/$branch" 2>/dev/null; then
        if git push -u origin "$branch" >/dev/null 2>&1; then
            cliInfo "branch pushed: $branch"
            printf '\n'
        else
            cliWarning "failed to push $branch to origin"
        fi
    fi
}

flowUpdateBranchFromMain() {
    local branch="$1" worktree tmp
    local branch_tree main_tree
    branch_tree=$(git rev-parse "$branch^{tree}" 2>/dev/null)
    main_tree=$(git rev-parse "$FLOW_MAIN_BRANCH^{tree}" 2>/dev/null)
    if [ -n "$branch_tree" ] && [ "$branch_tree" = "$main_tree" ]; then
        worktree=$(flowBranchWorktree "$branch")
        if [ -n "$worktree" ]; then
            if [ -n "$(git -C "$worktree" status --porcelain)" ]; then
                cliWarning "$branch is checked out dirty in $worktree - reset skipped"
                return 1
            fi
            git -C "$worktree" reset --hard "$FLOW_MAIN_BRANCH" >/dev/null 2>&1
        else
            git push . "+$FLOW_MAIN_BRANCH:$branch" >/dev/null 2>&1
        fi
        if flowHasRemote; then
            git push --force-with-lease origin "$branch" >/dev/null 2>&1 || {
                cliWarning "failed to push the $branch reset"
                return 1
            }
        fi
        printf -- '- reset: %s -> %s (content identical);\n' "$branch" "$FLOW_MAIN_BRANCH"
        return 0
    fi
    if flowBranchPatchesIn "$branch" "$FLOW_MAIN_BRANCH"; then
        worktree=$(flowBranchWorktree "$branch")
        if [ -n "$worktree" ]; then
            if [ -n "$(git -C "$worktree" status --porcelain)" ]; then
                cliWarning "$branch is checked out dirty in $worktree - reset skipped"
                return 1
            fi
            git -C "$worktree" reset --hard "$FLOW_MAIN_BRANCH" >/dev/null 2>&1
        else
            git push . "+$FLOW_MAIN_BRANCH:$branch" >/dev/null 2>&1
        fi
        if flowHasRemote; then
            git push --force-with-lease origin "$branch" >/dev/null 2>&1 || {
                cliWarning "failed to push the $branch reset"
                return 1
            }
        fi
        printf -- '- reset: %s -> %s (fully promoted);\n' "$branch" "$FLOW_MAIN_BRANCH"
        return 0
    fi
    if [ "$branch" = "$(flowCurrentBranch)" ]; then
        flowRequireCleanTree || return 1
        if ! git merge --no-edit "$FLOW_MAIN_BRANCH"; then
            cliError "conflict syncing $FLOW_MAIN_BRANCH into $branch - resolve manually"
            return 1
        fi
        git push origin "$branch" >/dev/null 2>&1 || {
            cliWarning "failed to push $branch"
            return 1
        }
        printf -- '- synced: %s -> %s;\n' "$FLOW_MAIN_BRANCH" "$branch"
        return 0
    fi
    worktree=$(flowBranchWorktree "$branch")
    if [ -n "$worktree" ]; then
        if [ -n "$(git -C "$worktree" status --porcelain)" ]; then
            cliWarning "$branch is checked out dirty in $worktree - sync skipped"
            cliHint "git -C $worktree merge $FLOW_MAIN_BRANCH"
            return 1
        fi
        if ! git -C "$worktree" merge --no-edit "$FLOW_MAIN_BRANCH"; then
            cliError "conflict syncing $FLOW_MAIN_BRANCH into $branch - resolve manually"
            return 1
        fi
        git -C "$worktree" push origin "$branch" >/dev/null 2>&1 || {
            cliWarning "failed to push $branch"
            return 1
        }
        printf -- '- synced: %s -> %s;\n' "$FLOW_MAIN_BRANCH" "$branch"
        return 0
    fi
    if git fetch . "$FLOW_MAIN_BRANCH:$branch" 2>/dev/null; then
        git push origin "$branch" >/dev/null 2>&1 || {
            cliWarning "failed to push $branch"
            return 1
        }
        printf -- '- synced: %s -> %s;\n' "$FLOW_MAIN_BRANCH" "$branch"
        return 0
    fi
    tmp=$(mktemp -d)
    if git worktree add "$tmp" "$branch" >/dev/null 2>&1; then
        if git -C "$tmp" merge --no-edit "$FLOW_MAIN_BRANCH" >/dev/null 2>&1; then
            git push origin "$branch" >/dev/null 2>&1
            git worktree remove --force "$tmp" >/dev/null 2>&1
            printf -- '- synced: %s -> %s (merged);\n' "$FLOW_MAIN_BRANCH" "$branch"
            return 0
        fi
        cliError "conflict syncing $FLOW_MAIN_BRANCH into $branch - resolve in $tmp (worktree kept)"
        return 1
    fi
    rm -rf "$tmp"
    cliWarning "$branch cannot sync with $FLOW_MAIN_BRANCH - sync manually"
    cliHint "git checkout $branch && git merge $FLOW_MAIN_BRANCH"
    return 1
}

flowBranchPatchesIn() { # branch ref -> 0 when every branch commit is patch-equivalent to ref
    local branch="$1" ref="$2" ahead
    git show-ref --verify --quiet "refs/remotes/origin/$ref" 2>/dev/null && ref="origin/$ref"
    ahead=$(git cherry "$ref" "$branch" 2>/dev/null | grep -c '^+')
    [ "$ahead" = "0" ]
}

flowCleanupMergedBranches() { # removes task/hotfix branches fully patch-equivalent to origin/main
    local branch worktree ahead merged=""
    for branch in $(git for-each-ref --format='%(refname:short)' \
        'refs/heads/task-*' 'refs/heads/hotfix-*'); do
        flowBranchPatchesIn "$branch" "$FLOW_MAIN_BRANCH" || continue
        merged="$merged $branch"
    done
    [ -z "$merged" ] && return 0
    cliInfo "merged task branches to clean up:"
    printf '\n'
    for branch in $merged; do
        printf -- '- %s;\n' "$branch"
    done
    printf '\n'
    if ! flowConfirm "Remove the merged branches (and their worktrees)?"; then
        cliInfo "declined - the branches stay"
        printf '\n'
        return 0
    fi
    for branch in $merged; do
        worktree=$(flowBranchWorktree "$branch")
        if [ -n "$worktree" ]; then
            if [ -n "$(git -C "$worktree" status --porcelain)" ]; then
                cliWarning "the $branch worktree is dirty in $worktree - skipped"
                printf '\n' >&2
                continue
            fi
            git worktree remove "$worktree" >/dev/null 2>&1 || \
                git worktree remove --force "$worktree" >/dev/null 2>&1
        fi
        git branch -D "$branch" >/dev/null 2>&1
        if git show-ref --verify --quiet "refs/remotes/origin/$branch" 2>/dev/null; then
            git push origin --delete "$branch" >/dev/null 2>&1
        fi
        printf -- '- removed: %s;\n' "$branch"
    done
    printf '\n'
}

flowMergeRequestUrl() {
    local branch="$1" target="$2" url
    url=$(git remote get-url origin 2>/dev/null)
    if [ -z "$url" ]; then
        cliWarning "no origin remote - create the merge request manually: $branch -> $target"
        return 0
    fi
    case "$url" in
        git@*)
            url=$(printf '%s' "${url#git@}" | sed 's|\.git$||; s|:|/|')
            url="https://$url"
            ;;
        *.git)
            url="${url%.git}"
            ;;
    esac
    case "$url" in
        *github.com*)
            if [ "$target" != "$FLOW_MAIN_BRANCH" ]; then
                printf '%s\n' "$url/compare/$target...$branch?expand=1"
            else
                printf '%s\n' "$url/pull/new/$branch"
            fi
            ;;
        *gitlab*)
            printf '%s\n' "$url/-/merge_requests/new?merge_request%5Bsource_branch%5D=$branch"
            ;;
        *)
            cliWarning "unknown forge - create the merge request manually: $branch -> $target ($url)"
            ;;
    esac
}
