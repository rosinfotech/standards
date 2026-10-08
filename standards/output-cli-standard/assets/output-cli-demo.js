#!/usr/bin/env node
import readline from "node:readline/promises";

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

function colorEnabled(stream) {
    if (process.env.CLICOLOR_FORCE && process.env.CLICOLOR_FORCE !== "0") return true;
    if (process.env.NO_COLOR !== undefined && process.env.NO_COLOR !== "") return false;
    if (process.env.CLICOLOR === "0") return false;
    if (process.env.TERM === "dumb") return false;
    return Boolean(stream.isTTY);
}

function painter(stream) {
    const on = colorEnabled(stream);
    const wrap = (code) => (text) => (on ? `\u001b[${code}m${text}\u001b[0m` : text);
    return {
        blue: wrap("94"),
        bold: wrap("1"),
        cyan: wrap("36"),
        gray: wrap("90"),
        green: wrap("32"),
        red: wrap("31"),
        white: wrap("97"),
        yellow: wrap("33"),
    };
}

function colorJson(text, out) {
    return text.replace(
        /("(?:\\.|[^"\\])*")(\s*:)?|\b(true|false|null)\b|(-?\d+(?:\.\d+)?)/g,
        (match, str, colon) => {
            if (str !== undefined) {
                return colon !== undefined ? out.cyan(str) + colon : out.green(str);
            }
            return out.yellow(match);
        },
    );
}

async function deploy() {
    const out = painter(process.stdout);
    const err = painter(process.stderr);
    process.stdout.write(`${out.bold(out.blue("== Deploy report =="))}\n\n`);
    process.stdout.write(`${out.bold(out.blue("-- Region EU --"))}\n\n`);
    process.stdout.write("- server-a: restarted;\n");
    process.stdout.write("- config: updated;\n");
    process.stdout.write("- server-b: skipped, no changes detected;\n");
    process.stderr.write(`\n${err.yellow(err.bold("Warning:"))} ${err.yellow("2 flaky tests skipped")}\n\n`);
    process.stderr.write(`${err.green(err.bold("Success:"))} ${err.green("deployed in 8.2s")}\n`);
    return 0;
}

async function doctor() {
    const out = painter(process.stdout);
    const err = painter(process.stderr);
    process.stdout.write(`${out.bold(out.blue("== Health report =="))}\n\n`);
    process.stdout.write(`${out.bold(out.blue("-- Checks --"))}\n\n`);
    process.stdout.write("Name      Status    Note\n");
    process.stdout.write("db        ok        12 migrations pending\n");
    process.stdout.write("cache     ok        hit rate 94%\n");
    process.stdout.write("disk      warning   82% used\n");
    process.stderr.write(`\n${err.yellow(err.bold("Warning:"))} ${err.yellow("disk usage above 80%")}\n\n`);
    process.stderr.write(`${err.cyan(err.bold("Information:"))} ${err.cyan("next maintenance window on Sunday 02:00")}\n\n`);
    process.stdout.write(`${out.green(out.bold("Success:"))} ${out.green("2 ok, 1 warning")}\n`);
    return 0;
}

async function maintenance() {
    const out = painter(process.stdout);
    const err = painter(process.stderr);
    process.stdout.write(`${out.bold(out.blue("== Server: hissing-gray =="))}\n\n`);
    process.stdout.write("OS: ubuntu (settings.os) -> family: debian\n\n");
    process.stderr.write(`${err.yellow(err.bold("Warning:"))} ${err.yellow("pending updates: 2 (security: 1):")}\n\n`);
    process.stdout.write("    - docker-buildx-plugin/resolute 0.38.0-1~ubuntu.26.04 amd64;\n");
    process.stdout.write("    - libpng16-16t64/resolute 1.6.57-1ubuntu0.1 amd64;\n");
    process.stdout.write("    - openssh-client/resolute 1:10.2p1-2ubuntu3.7 amd64;\n\n");
    process.stdout.write(`${out.bold(out.blue("== Disk usage (df -h) =="))}\n\n`);
    process.stdout.write("Filesystem      Size  Used Avail Use% Mounted on\n");
    process.stdout.write("tmpfs           1.6G  1.2M  1.6G   1% /run\n");
    process.stdout.write("/dev/vda2       118G   11G  102G  10% /\n\n");
    process.stderr.write(`${err.cyan(err.bold("Information:"))} ${err.cyan("the df -h block above is the relayed utility output - passed through as-is")}\n\n`);
    process.stderr.write(`${err.green(err.bold("Success:"))} ${err.green("maintenance report generated in 3.1s")}\n`);
    return 0;
}

async function json() {
    const out = painter(process.stdout);
    const payload = { items: [{ name: "src", status: "ok" }, { name: "docs", status: "skipped" }] };
    if (process.stdout.isTTY) {
        process.stdout.write(`${colorJson(JSON.stringify(payload, null, 4), out)}\n`);
    } else {
        process.stdout.write(`${JSON.stringify(payload)}\n`);
    }
    return 0;
}

async function list() {
    const out = painter(process.stdout);
    process.stdout.write(`${out.bold(out.blue("-- Source files --"))}\n\n`);
    process.stdout.write(`- ${out.cyan("src/cli.ts")};\n`);
    process.stdout.write(`- ${out.cyan("src/main.ts")};\n`);
    return 0;
}

async function progress() {
    const err = painter(process.stderr);
    const total = 12;
    for (let i = 1; i <= total; i += 1) {
        await sleep(70);
        if (process.stderr.isTTY) {
            process.stderr.write(`\rFetching migrations... ${i}/${total}   `);
        }
    }
    if (process.stderr.isTTY) {
        process.stderr.write("\r\u001b[K");
    }
    process.stderr.write(`${err.green(err.bold("Success:"))} ${err.green(`${total} migrations fetched in 0.9s`)}\n`);
    return 0;
}

async function prompt() {
    const err = painter(process.stderr);
    if (!process.stdin.isTTY || !process.stdout.isTTY) {
        process.stderr.write(
            `${err.red(err.bold("Error:"))} ${err.red("interactive prompt requires a terminal; rerun with --yes")}\n`,
        );
        return 2;
    }
    process.stdout.write("Deploy to production?\n\n");
    process.stdout.write("    1) yes\n");
    process.stdout.write("    2) no\n\n");
    process.stdout.write("Choose [1]: ");
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
    const answer = await rl.question("");
    rl.close();
    const choice = answer.trim() === "" ? "1" : answer.trim();
    process.stdout.write(choice === "1" ? "Deploying...\n" : "Cancelled\n");
    return 0;
}

async function report() {
    const out = painter(process.stdout);
    const err = painter(process.stderr);
    process.stdout.write(`${out.bold(out.blue("== Deploy report =="))}\n\n`);
    process.stdout.write(`${out.bold(out.blue("-- Changes --"))}\n\n`);
    process.stdout.write(`${out.blue("-- Region EU --")}\n\n`);
    process.stdout.write(`${out.bold(out.white("Checks"))}\n\n`);
    process.stdout.write("- server-a:\n\n");
    process.stdout.write("    - restarted at 12:04;\n");
    process.stdout.write("    - uptime 3m;\n\n");
    process.stdout.write("- config:\n\n");
    process.stdout.write("    - updated 2 keys:\n\n");
    process.stdout.write("        - log level to warning;\n");
    process.stdout.write("        - cache ttl to 300s;\n\n");
    process.stdout.write("    - backup created;\n\n");
    process.stdout.write("- server-b:\n\n");
    process.stdout.write("    - skipped, no changes detected;\n\n");
    process.stdout.write(`${out.bold(out.blue("-- Verification --"))}\n\n`);
    process.stdout.write(`${out.blue("-- Tests --")}\n\n`);
    process.stdout.write(`${out.bold(out.white("Summary"))}\n\n`);
    process.stdout.write("- migrations: 4 applied;\n");
    process.stdout.write("- tests:\n\n");
    process.stdout.write("    - 212 passed;\n");
    process.stdout.write("    - 2 skipped:\n\n");
    process.stdout.write("        - flaky: auth-login-flow;\n");
    process.stdout.write("        - requires live db: export-import;\n\n");
    process.stderr.write(`${err.yellow(err.bold("Warning:"))} ${err.yellow("2 tests skipped")}\n\n`);
    process.stderr.write(`${err.green(err.bold("Success:"))} ${err.green("deployed in 8.2s")}\n`);
    return 0;
}

async function runtimeError() {
    const err = painter(process.stderr);
    process.stderr.write(`${err.red(err.bold("Error:"))}\n\n`);
    process.stderr.write(`    ${err.red("server-b: failed to connect. The timeout of 5s expired before the handshake.")}\n\n`);
    process.stderr.write(`${err.gray("Hint: check the VPN tunnel before retrying")}\n`);
    return 1;
}

async function tsv() {
    process.stdout.write("name\tstatus\tregion\n");
    process.stdout.write("src\tok\teu\n");
    process.stdout.write("docs\tskipped\teu\n");
    return 0;
}

async function usageError() {
    const err = painter(process.stderr);
    process.stderr.write(`${err.red(err.bold("Error:"))} ${err.red('unknown flag "--regoin"')}\n\n`);
    process.stderr.write(`${err.gray('Hint: did you mean "--region"?')}\n`);
    process.stderr.write(`${err.gray('Run "mycli deploy --help" for usage.')}\n`);
    return 2;
}

async function wrap() {
    const err = painter(process.stderr);
    process.stderr.write(
        `${err.yellow(err.bold("Warning:"))} ${err.yellow('the migration 2610071900 "rename user activation timestamp column" was\n')}`,
    );
    process.stderr.write(`    ${err.yellow("skipped because its precondition failed")}\n\n`);
    process.stderr.write(
        `${err.red(err.bold("Error:"))} ${err.red("cannot read src/features/deployment/…/config.production.yaml")}\n\n`,
    );
    process.stderr.write(`${err.gray("Hint: run with --verbose for the full path")}\n`);
    return 1;
}

const scenarios = {
    deploy,
    doctor,
    json,
    list,
    maintenance,
    progress,
    prompt,
    report,
    runtimeError,
    tsv,
    usageError,
    wrap,
};

const requested = process.argv[2] ?? "all";
const names = Object.keys(scenarios);

if (requested !== "all" && !(requested in scenarios)) {
    process.stderr.write(`Error: unknown scenario "${requested}"\n`);
    process.stderr.write(`Hint: run one of: ${names.join(", ")}\n`);
    process.exitCode = 2;
} else {
    const runList = requested === "all" ? names : [requested];
    for (const name of runList) {
        if (requested === "all") {
            const err = painter(process.stderr);
            process.stdout.write(`\n${err.bold(name)}\n\n`);
        }
        if (process.stdout.isTTY) {
            process.stdout.write("\n");
        }
        process.exitCode = await scenarios[name]();
        if (process.stdout.isTTY) {
            process.stdout.write("\n");
        }
    }
    if (requested === "all") {
        process.exitCode = 0;
    }
}
