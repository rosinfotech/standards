#!/bin/bash
#
# cli_lib.sh - the Output CLI Standard primitives (the rules #2610072030 -
# #2610072050): the stream split, the exit-code contract, the color gating
# chain, the closed semantic palette, the marker headers and the message
# prefixes. A library: sourced by the framework commands.

cliColorGates() {
    local tty_state="$1"
    if [ -n "$CLICOLOR_FORCE" ] && [ "$CLICOLOR_FORCE" != "0" ]; then echo 1; return; fi
    if [ -n "$NO_COLOR" ]; then echo 0; return; fi
    if [ "$CLICOLOR" = "0" ]; then echo 0; return; fi
    if [ "$TERM" = "dumb" ]; then echo 0; return; fi
    echo "$tty_state"
}

if [ -t 1 ]; then CLI_COLOR_OUT=$(cliColorGates 1); else CLI_COLOR_OUT=$(cliColorGates 0); fi
if [ -t 2 ]; then CLI_COLOR_ERR=$(cliColorGates 1); else CLI_COLOR_ERR=$(cliColorGates 0); fi

CLI_RESET=$'\033[0m'
CLI_BLUE=$'\033[94m'
CLI_WHITE=$'\033[97m'
CLI_RED=$'\033[91m'
CLI_YELLOW=$'\033[93m'
CLI_GREEN=$'\033[92m'
CLI_CYAN=$'\033[96m'
CLI_GRAY=$'\033[90m'
CLI_BOLD=$'\033[1m'

cliHeader1() {
    if [ "$CLI_COLOR_OUT" = "1" ]; then
        printf '%s%s== %s ==%s\n' "$CLI_BOLD" "$CLI_BLUE" "$1" "$CLI_RESET"
    else
        printf '== %s ==\n' "$1"
    fi
}

cliHeader1Err() {
    if [ "$CLI_COLOR_ERR" = "1" ]; then
        printf '%s%s== %s ==%s\n' "$CLI_BOLD" "$CLI_BLUE" "$1" "$CLI_RESET" >&2
    else
        printf '== %s ==\n' "$1" >&2
    fi
}

cliHeader2() {
    if [ "$CLI_COLOR_OUT" = "1" ]; then
        printf '%s%s-- %s --%s\n' "$CLI_BOLD" "$CLI_BLUE" "$1" "$CLI_RESET"
    else
        printf -- '-- %s --\n' "$1"
    fi
}

cliHeader3() {
    if [ "$CLI_COLOR_OUT" = "1" ]; then
        printf '%s-- %s --%s\n' "$CLI_BLUE" "$1" "$CLI_RESET"
    else
        printf -- '-- %s --\n' "$1"
    fi
}

cliHeader3Err() {
    if [ "$CLI_COLOR_ERR" = "1" ]; then
        printf '%s-- %s --%s\n' "$CLI_BLUE" "$1" "$CLI_RESET" >&2
    else
        printf -- '-- %s --\n' "$1" >&2
    fi
}

cliHeader4() {
    if [ "$CLI_COLOR_OUT" = "1" ]; then
        printf '%s%s%s%s\n' "$CLI_BOLD" "$CLI_WHITE" "$1" "$CLI_RESET"
    else
        printf '%s\n' "$1"
    fi
}

cliError() {
    if [ "$CLI_COLOR_ERR" = "1" ]; then
        printf '%sError:%s %s%s\n' "${CLI_BOLD}${CLI_RED}" "$CLI_RESET" "$CLI_RED$*" "$CLI_RESET" >&2
    else
        printf 'Error: %s\n' "$*" >&2
    fi
}

cliWarning() {
    if [ "$CLI_COLOR_ERR" = "1" ]; then
        printf '%sWarning:%s %s%s\n' "${CLI_BOLD}${CLI_YELLOW}" "$CLI_RESET" "$CLI_YELLOW$*" "$CLI_RESET" >&2
    else
        printf 'Warning: %s\n' "$*" >&2
    fi
}

cliSuccess() {
    if [ "$CLI_COLOR_OUT" = "1" ]; then
        printf '%sSuccess:%s %s%s\n' "${CLI_BOLD}${CLI_GREEN}" "$CLI_RESET" "$CLI_GREEN$*" "$CLI_RESET"
    else
        printf 'Success: %s\n' "$*"
    fi
}

cliInfo() {
    if [ "$CLI_COLOR_OUT" = "1" ]; then
        printf '%sInformation:%s %s%s\n' "${CLI_BOLD}${CLI_CYAN}" "$CLI_RESET" "$CLI_CYAN$*" "$CLI_RESET"
    else
        printf 'Information: %s\n' "$*"
    fi
}

cliHint() {
    if [ "$CLI_COLOR_ERR" = "1" ]; then
        printf '%sHint:%s %s%s\n' "${CLI_GRAY}" "$CLI_RESET" "$CLI_GRAY$*" "$CLI_RESET" >&2
    else
        printf 'Hint: %s\n' "$*" >&2
    fi
}

cliPath() {
    if [ "$CLI_COLOR_OUT" = "1" ]; then
        printf '%s%s%s' "$CLI_CYAN" "$1" "$CLI_RESET"
    else
        printf '%s' "$1"
    fi
}

cliFrameOpen() {
    if [ -t 1 ]; then printf '\n'; fi
}

cliFrameClose() {
    if [ -t 1 ]; then printf '\n'; fi
}

cliFrameInit() {
    cliFrameOpen
    trap 'cliFrameClose' EXIT
}
