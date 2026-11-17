#!/usr/bin/env node
import readline from "node:readline/promises";


const SCRIPT = "output-cli-demo.js";

const THEMES = {
    dark: {
        cyan: "96",
        green: "92",
        gray: "90",
        red: "91",
        text: "38;5;251",
        white: "97",
        yellow: "93",
    },
    light: {
        cyan: "38;5;25",
        green: "38;5;28",
        gray: "38;5;246",
        red: "31",
        text: "38;5;239",
        white: "30",
        yellow: "38;5;130",
    },
};

const CODE_NOTES = {
    dark: {
        cyan: "Bright cyan (96)",
        green: "Bright green (92)",
        gray: "Bright black (90)",
        red: "Bright red (91)",
        text: "Light gray (38;5;251)",
        white: "Bright white (97)",
        yellow: "Bright yellow (93)",
    },
    light: {
        cyan: "Blue (38;5;25)",
        green: "Dark green (38;5;28)",
        gray: "Gray (38;5;246)",
        red: "Red (31)",
        text: "Dark gray (38;5;239)",
        white: "Black (30)",
        yellow: "Amber (38;5;130)",
    },
};

const MESSAGE_ROLES = {
    Error: "red",
    Information: "cyan",
    Success: "green",
    Warning: "yellow",
};

const PALETTE_ROLES = [
    ["Heading 1", "cyan"],
    ["Heading 2", "white"],
    ["Prompt", "cyan"],
    ["Information", "cyan"],
    ["Success", "green"],
    ["Warning", "yellow"],
    ["Error", "red"],
    ["Text", "text"],
    ["Hint", "gray"],
];

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

const capitalize = (text) => text.charAt(0).toUpperCase() + text.slice(1);

function paragraphText(unit, sentenceCounts) {
    return sentenceCounts
        .map((count) => {
            const units = Array.from({ length: count }, () => unit).join(" ");
            return `${capitalize(units)}.`;
        })
        .join(" ");
}

let colorOverride = null;

function colorEnabled(stream) {
    if (colorOverride !== null) return colorOverride;
    return Boolean(stream.isTTY);
}

let framed = false;

function lead() {
    if (framed) return "";
    framed = true;
    return "\n";
}

function painter(stream, themeName) {
    const on = colorEnabled(stream);
    const codes = THEMES[themeName];
    const wrap = (code) => (text) => (on ? `[${code}m${text}[0m` : text);
    const p = {
        ansi: (code, text) => (on ? `[${code}m${text}[0m` : text),
        cyan: wrap(codes.cyan),
        green: wrap(codes.green),
        gray: wrap(codes.gray),
        heading1: (text) => p.cyan(text),
        heading2: (text) => p.white(text),
        hint: (text) => {
            const body = capitalize(text);
            const closed = /[.!?]$/.test(body) ? body : `${body}.`;
            return p.gray(`Hint. ${closed}`);
        },
        key: (text) => p.cyan(text),
        message: (type, text) => {
            const role = MESSAGE_ROLES[type];
            const body = capitalize(text);
            return type === "Information" ? p[role](body) : p[role](`${type}. ${body}`);
        },
        prompt: (text) => p.cyan(text),
        red: wrap(codes.red),
        text: wrap(codes.text),
        theme: themeName,
        white: wrap(codes.white),
        yellow: wrap(codes.yellow),
    };
    return p;
}

function render(blocks) {
    process.stdout.write(`${lead()}${blocks.join("\n\n")}\n\n`);
}

function paletteBlocks(p) {
    const rows = PALETTE_ROLES.map(([name, key]) => ({
        dark: CODE_NOTES.dark[key],
        key,
        light: CODE_NOTES.light[key],
        name,
    }));
    const gap = 2;
    const width = (title, key) => Math.max(title.length, ...rows.map((row) => row[key].length));
    const widthRole = width("Role", "name");
    const widthDark = width("Dark", "dark");
    const widthLight = width("Light", "light");
    const header = `${"Role".padEnd(widthRole + gap)}${"Dark".padEnd(widthDark + gap)}Light`;
    const dashes = `${"-".repeat(widthRole).padEnd(widthRole + gap)}`
        + `${"-".repeat(widthDark).padEnd(widthDark + gap)}`
        + `${"-".repeat(widthLight)}`;
    const lines = rows.map((row) => {
        const name = p[row.key](row.name.padEnd(widthRole + gap));
        const dark = p.ansi(THEMES.dark[row.key], row.dark.padEnd(widthDark + gap));
        return `${name}${dark}${p.ansi(THEMES.light[row.key], row.light)}`;
    });
    const other = p.theme === "dark" ? "light" : "dark";
    return [
        p.heading1(`Palette: ${p.theme} theme`),
        p.hint(`enable the ${other} theme: node ${SCRIPT} --theme=${other}`),
        p.heading2("Colors"),
        [p.white(header), p.white(dashes), ...lines].join("\n"),
    ];
}

function headersBlocks(p) {
    return [
        p.heading1("Heading 1"),
        p.heading2("Heading 2"),
        p.text(paragraphText("heading", [8])),
    ];
}

function messagesBlocks(p) {
    return [
        p.heading1("Specific blocks"),
        p.message("Information", paragraphText("information", [8, 8])),
        p.message("Success", paragraphText("success", [8, 8])),
        p.message("Warning", paragraphText("warning", [8, 8])),
        p.message("Error", paragraphText("error", [8, 8])),
        p.hint(paragraphText("hint", [8, 8])),
    ];
}

function paragraphsBlocks(p) {
    return [
        p.heading1("Paragraphs"),
        p.text(paragraphText("paragraph 1", [18, 16, 18])),
        p.text(paragraphText("paragraph 2", [15, 13])),
    ];
}

function listsBlocks(p) {
    return [
        p.heading1("Lists"),
        p.heading2("List 1"),
        p.text([
            "- Item 1:",
            "",
            "    - Item 1.1:",
            "",
            "        - Item 1.1.1;",
            "        - Item 1.1.2;",
            "",
            "    - Item 1.2:",
            "",
            "        - Item 1.2.1;",
            "        - Item 1.2.2;",
            "",
            "- Item 2:",
            "",
            "    - Item 2.1;",
            "    - Item 2.2;",
        ].join("\n")),
        p.heading2("List 2"),
        p.text([
            "1. Item 1:",
            "",
            "    1. Item 1.1;",
            "    2. Item 1.2;",
            "",
            "2. Item 2:",
            "",
            "    1. Item 2.1;",
            "    2. Item 2.2;",
        ].join("\n")),
    ];
}

function promptsBlocks(p) {
    return [
        p.heading1("Prompts"),
        p.prompt("Prompt 1 [Y/n]?"),
        p.prompt(
            "Prompt 2:\n\n    1) Option 1;\n    2) Option 2;\n    3) Option 3;\n\nChoose [1]:",
        ),
    ];
}

function keysBlocks(p) {
    const item = (name, rest) => `${p.text("- ")}${p.key(name)}${p.text(rest)}`;
    const para = (parts) => parts.join("");
    return [
        p.heading1("Keys"),
        [
            item("--option-1", " – the first option;"),
            item("--option-2", " – the second option;"),
            item("--option-3", " – the third option;"),
        ].join("\n"),
        para([
            p.text("The "),
            p.key("--option-1"),
            p.text(" flag configures the value; the "),
            p.key("--option-2"),
            p.text(" flag selects the scenario."),
        ]),
    ];
}

function usageBlocks(p) {
    const item = (name, rest) => `${p.text("- ")}${p.key(name)}${p.text(rest)}`;
    const option = (name, rest) => `${p.text("- ")}${p.key(name)}${p.text(rest)}`;
    return [
        p.heading1(SCRIPT),
        p.text("Renders the proposed output rules of the Output CLI standard."),
        p.heading2("Scenarios"),
        [
            item("All", ": palette, headers, messages, paragraphs, lists, prompts (default);"),
            item("Headers", ": heading levels (rule 2);"),
            item("JSON", ": machine output, JSON;"),
            item("Keys", ": key phrases in lists, text and messages;"),
            item("Lists", ": nested dash and numbered lists;"),
            item("Messages", ": special message blocks (rule 3);"),
            item("Palette", ": the palette colors (rules 1.1, 1.2);"),
            item("Paragraphs", ": multi-sentence paragraph blocks;"),
            item("Progress", ": one-line progress on stderr;"),
            item("Prompts", ": [Y/n] and numeric menu prompt blocks;"),
            item("TSV", ": machine output, TSV;"),
        ].join("\n"),
        p.heading2("Options"),
        [
            option("--theme", " dark|light: select the palette (default: dark);"),
            option("--color", ": force the color on, even into a pipe;"),
            option("--no-color", ": force the color off;"),
            option("--help", ": print this usage;"),
        ].join("\n"),
    ];
}

function jsonScenario() {
    const payload = {
        items: [
            { name: "item 1", status: "status 1" },
            { name: "item 2", status: "status 2" },
        ],
    };
    if (process.stdout.isTTY) {
        process.stdout.write(`${JSON.stringify(payload, null, 4)}\n\n`);
    } else {
        process.stdout.write(`${JSON.stringify(payload)}\n\n`);
    }
    return 0;
}

function tsvScenario() {
    process.stdout.write("name\tstatus\tregion\n");
    process.stdout.write("item 1\tstatus 1\tregion 1\n");
    process.stdout.write("item 2\tstatus 2\tregion 1\n\n");
    return 0;
}

async function progressScenario(themeName) {
    const p = painter(process.stdout, themeName);
    process.stdout.write(lead());
    const total = 12;
    for (let i = 1; i <= total; i += 1) {
        await sleep(70);
        if (process.stdout.isTTY) {
            process.stdout.write(`\rProgress ${i}/${total}   `);
        }
    }
    if (process.stdout.isTTY) {
        process.stdout.write("\r[K");
    }
    process.stdout.write(`${p.message("Success", "progress completed")}\n\n`);
    return 0;
}

async function promptScenario(themeName) {
    const p = painter(process.stdout, themeName);
    if (!process.stdin.isTTY || !process.stdout.isTTY) {
        const text = "interactive prompt requires a terminal; rerun with --yes";
        process.stdout.write(`${lead()}${p.message("Error", text)}\n\n`);
        return 2;
    }
    process.stdout.write(lead());
    process.stdout.write(p.prompt("Prompt 1 [Y/n]? "));
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
    const answer = await rl.question("");
    rl.close();
    const answerText = answer.trim().toLowerCase();
    const confirmed = answerText === "" || answerText.startsWith("y");
    const verdict = confirmed
        ? p.message("Success", "confirmed")
        : p.message("Information", "cancelled");
    process.stdout.write(`\n${verdict}\n\n`);
    return 0;
}

function fail(themeName, text) {
    const known = themeName in THEMES ? themeName : "dark";
    const e = painter(process.stdout, known);
    process.stdout.write(`${lead()}${e.message("Error", text)}\n\n`);
    return 2;
}

const RENDER_SCENARIOS = {
    headers: headersBlocks,
    keys: keysBlocks,
    lists: listsBlocks,
    messages: messagesBlocks,
    palette: paletteBlocks,
    paragraphs: paragraphsBlocks,
    prompts: promptsBlocks,
};

async function main() {
    let scenario = "all";
    let themeName = "dark";
    const argv = process.argv.slice(2);
    for (let i = 0; i < argv.length; i += 1) {
        const arg = argv[i];
        if (arg === "--help" || arg === "-h") {
            render(usageBlocks(painter(process.stdout, themeName)));
            return 0;
        }
        if (arg === "--theme") {
            themeName = argv[i + 1];
            i += 1;
        } else if (arg.startsWith("--theme=")) {
            themeName = arg.slice(8);
        } else if (arg === "--color") {
            colorOverride = true;
        } else if (arg === "--no-color") {
            colorOverride = false;
        } else if (arg.startsWith("-")) {
            return fail(themeName, `unknown flag "${arg}"`);
        } else {
            scenario = arg;
        }
    }
    if (!(themeName in THEMES)) {
        return fail(themeName, `unknown theme "${themeName}"`);
    }
    if (scenario === "all") {
        const p = painter(process.stdout, themeName);
        const blocks = [
            ...paletteBlocks(p),
            ...headersBlocks(p),
            ...messagesBlocks(p),
            ...paragraphsBlocks(p),
            ...listsBlocks(p),
            ...keysBlocks(p),
            ...promptsBlocks(p),
        ];
        render(blocks);
        return 0;
    }
    if (scenario in RENDER_SCENARIOS) {
        render(RENDER_SCENARIOS[scenario](painter(process.stdout, themeName)));
        return 0;
    }
    if (scenario === "json") return jsonScenario();
    if (scenario === "progress") return progressScenario(themeName);
    if (scenario === "prompt") return promptScenario(themeName);
    if (scenario === "tsv") return tsvScenario();
    return fail(themeName, `unknown scenario "${scenario}"`);
}

main().then((code) => {
    process.exitCode = code;
});
