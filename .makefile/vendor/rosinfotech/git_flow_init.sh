#!/bin/bash

LIB_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$LIB_DIR/flow_lib.sh"

flowInit() {

    local variant="$1"
    local catalog line asset name marker
    local existing same=0 base train version

    if [ -z "$variant" ]; then
        cliError "the variant number is required"
        printf '\n' >&2
        cliHeader3Err "Variants (the Git Flow Standard ladder)"
        printf '\n' >&2
        flowStandardCatalog | sort -n | while IFS="$(printf '\t')" read -r row_number row_name row_asset; do
            printf '%s  %s\n' "$row_number" "$row_name" >&2
        done
        printf '\n' >&2
        cliHint "make git_flow_init <number>"
        exit 2
    fi

    echo "$variant" | grep -qE '^[0-9]+$' || {
        cliError "the variant must be a number - got '${variant}'"
        exit 2
    }

    flowRequireGitRepo

    catalog=$(flowStandardCatalog) || exit 1
    line=$(printf '%s\n' "$catalog" | awk -F '\t' -v n="$variant" '$1 == n')
    if [ -z "$line" ]; then
        cliError "variant #${variant} not found in the standard"
        exit 2
    fi
    name=$(printf '%s\n' "$line" | cut -f2)
    asset=$(printf '%s\n' "$line" | cut -f3)
    marker="$asset"

    mkdir -p "$FLOW_DIR"

    if [ -f "$FLOW_DIR/flow" ]; then
        mv "$FLOW_DIR/flow" "$FLOW_DIR/$asset"
        cliInfo "migrated the generic flow file into the asset-named $FLOW_DIR/$asset"
        printf '\n'
    fi

    for existing in "$FLOW_DIR"/"$FLOW_MARKER_PREFIX"*; do
        [ -e "$existing" ] || continue
        if [ "$existing" = "$FLOW_DIR/$asset" ]; then
            info=$(flowMarkerInfo "$existing")
            if [ "${info%%|*}" = "$variant" ]; then
                same=1
            else
                rm -f "$existing"
                cliWarning "replaced the flow file - a migration rides this change in one commit"
                printf '\n' >&2
            fi
        else
            rm -f "$existing"
            cliWarning "removed the old flow file $existing - a migration rides this change in one commit"
            printf '\n' >&2
        fi
    done

    for existing in ${FLOW_MARKER_PREFIX}*; do
        [ -e "$existing" ] || continue
        if git ls-files --error-unmatch "$existing" >/dev/null 2>&1; then
            git rm -q "$existing"
        else
            rm -f "$existing"
        fi
        cliInfo "migrated the legacy root marker away: $existing"
        printf '\n'
    done

    if [ -d "changelog-fragments" ]; then
        mkdir -p "$FLOW_FRAGMENTS_DIR"
        for fragment in changelog-fragments/*; do
            [ -e "$fragment" ] || continue
            mv "$fragment" "$FLOW_FRAGMENTS_DIR/"
        done
        rmdir changelog-fragments 2>/dev/null
        cliInfo "migrated legacy changelog-fragments/ into $FLOW_FRAGMENTS_DIR/"
        printf '\n'
    fi

    if [ "$same" -eq 1 ]; then
        cliInfo "flow already declared: $name ($FLOW_DIR/$asset)"
        printf '\n'
    elif [ -f ".makefile/flow-markers/$asset" ]; then
        cp ".makefile/flow-markers/$asset" "$FLOW_DIR/$asset"
        cliSuccess "flow file written: $FLOW_DIR/$asset (local override)"
        printf '\n'
    else
        flowFetchMarkerAsset "$asset" "$FLOW_DIR/$asset" || exit 1
        cliSuccess "flow file written: $FLOW_DIR/$asset (fetched from the standard)"
        printf '\n'
    fi

    if [ ! -f CHANGELOG.md ]; then
        {
            echo "<!-- markdownlint-disable MD041 -->"
            echo ""
            echo "# Changelog"
            echo ""
        } > CHANGELOG.md
        cliInfo "CHANGELOG.md created"
        printf '\n'
    fi

    git add "$FLOW_DIR" CHANGELOG.md 2>/dev/null
    if ! git diff --cached --quiet 2>/dev/null; then
        git commit -m "Changed: Flow variant #${variant} - ${name} declared" >/dev/null 2>&1 && {
            cliInfo "marker committed - the branch skeleton forks from the migrated main"
            printf '\n'
            if flowHasRemote; then
                if git push origin "$FLOW_MAIN_BRANCH" >/dev/null 2>&1; then
                    cliInfo "marker commit pushed to origin"
                    printf '\n'
                else
                    cliWarning "failed to push the marker commit - push main before platform merges"
                    printf '\n' >&2
                fi
            fi
        }
    fi

    if flowHasRemote; then
        git fetch origin >/dev/null 2>&1 || true
    fi

    base="$FLOW_MAIN_BRANCH"

    case "$variant" in
        3|4|5)
            flowEnsureBranch develop "$base"
            ;;
    esac

    if [ "$variant" = "4" ]; then
        flowEnsureBranch staging "$base"
    fi

    if [ "$variant" = "5" ]; then
        if [ -z "$(flowCurrentTrain)" ]; then
            version=$(flowLatestTag "$base")
            if [ -n "$version" ] && flowIsSemver "$version"; then
                train="release/$(flowBumpMinorBase "$version")"
            else
                train="release/0.1"
            fi
            flowEnsureBranch "$train" "$base"
            cliInfo "train created: $train (entering main stamps ${train#release/}.0)"
        fi
    fi

    cliHeader3 "Flow"
    printf '\n'
    printf -- '- variant: %s - %s;\n' "$variant" "$name"
    case "$variant" in
        1)
            printf -- '- work: make git_flow_commit_push "<Type>: <message>" (the commit is the stamp);\n'
            ;;
        2)
            printf -- '- work: git_flow_task_start -> git_flow_task_fragment -> git_flow_task_finish -> git_flow_stamp;\n'
            ;;
        3)
            printf -- '- work: git_flow_task_start -> git_flow_task_fragment -> git_flow_task_dev_merge -> git_flow_task_finish (MR) -> git_flow_stamp;\n'
            ;;
        4|5)
            printf -- '- work: git_flow_task_start -> git_flow_task_fragment -> git_flow_task_dev_merge -> git_flow_task_finish (MR) -> git_flow_prepare_release -> promotion MR -> git_flow_stamp;\n'
            ;;
        *)
            printf -- '- work: no branch scaffold for variant #%s - see the standard;\n' "$variant"
            ;;
    esac
    printf -- '- commit the marker: make git_flow_commit "Flow: Variant #%s - %s declared";\n' "$variant" "$name"

}

cliFrameInit
flowInit "$@"
