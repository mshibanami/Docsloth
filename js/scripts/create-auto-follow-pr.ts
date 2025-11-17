import { execSync } from "node:child_process";

const run = (cmd: string, options: { stdio?: "inherit" | "pipe" } = { stdio: "pipe" }) => {
    try {
        const out = execSync(cmd, { stdio: options.stdio ?? "pipe", encoding: "utf8" });
        return out?.toString() ?? "";
    } catch (e: any) {
        throw e;
    }
};

const env = process.env;
const repoFull = env.GITHUB_REPOSITORY || "";
const token = env.GITHUB_TOKEN || "";
if (!repoFull || !token) {
    console.error("GITHUB_REPOSITORY or GITHUB_TOKEN is not set. Please run this in GitHub Actions.");
    process.exit(1);
}
const [owner, repo] = repoFull.split("/");
const GITHUB_API = "https://api.github.com";
const BRANCH = "dependencies-update";

async function gh<T>(path: string, init?: RequestInit): Promise<T> {
    const res = await fetch(`${GITHUB_API}/repos/${owner}/${repo}${path}`, {
        ...init,
        headers: {
            "Authorization": `Bearer ${token}`,
            "Accept": "application/vnd.github+json",
            "X-GitHub-Api-Version": "2022-11-28",
            ...(init?.headers ?? {})
        },
    });
    if (!res.ok) {
        const text = await res.text().catch(() => "");
        throw new Error(`GitHub API error ${res.status} ${res.statusText} at ${path}: ${text}`);
    }
    return res.json() as Promise<T>;
}

async function main() {
    run(`git config user.name "github-actions[bot]"`);
    run(`git config user.email "41898282+github-actions[bot]@users.noreply.github.com"`);

    const repoInfo = await gh<{ default_branch: string }>("", {});
    const defaultBranch = repoInfo.default_branch || "main";

    run(`git pull --ff-only origin ${defaultBranch}`);

    console.log("Running: ncu -u");
    const ncuOutput = run(`pnpx npm-check-updates@latest -u`);
    console.log(ncuOutput || "(no ncu output)");
    console.log("Running: pnpm install");
    run(`pnpm install`, { stdio: "inherit" });
    console.log("Running: pnpm run build");
    try {
        run(`pnpm run build`, { stdio: "inherit" });
    } catch (e) {
        throw e;
    }

    const status = run(`git status --porcelain`);
    if (!status.trim()) {
        console.log("No dependency changes found. Finishing...");
        return;
    }

    console.log(`Preparing branch: ${BRANCH}`);
    run(`git checkout -B ${BRANCH} origin/${defaultBranch}`);
    run(`git add -A`);
    const sanitizedNcu = (ncuOutput || "").trim() || "No direct output from ncu.";
    const commitMessage = `chore(deps): automated dependencies update

ncu output:
${"```"}
${sanitizedNcu}
${"```"}
`;
    run(`git commit -m ${JSON.stringify(commitMessage)}`);
    run(`git push origin ${BRANCH} --force`);

    type Pull = { number: number; state: string; title: string; body: string | null };
    const prs = await gh<Pull[]>(
        `/pulls?state=open&head=${encodeURIComponent(`${owner}:${BRANCH}`)}&base=${encodeURIComponent(defaultBranch)}`
    );

    const prTitle = "chore(deps): automated dependencies update";
    const prBody =
        `This PR was created/updated automatically.\n\n` +
        `**Base**: \`${defaultBranch}\`\n**Head**: \`${BRANCH}\`\n\n` +
        `### ncu output\n` +
        "```\n" + sanitizedNcu + "\n```\n" +
        `### Notes\n- Ran \`ncu -u\`, \`npm install\`, and \`npm run build\`.\n` +
        `- This PR is force-pushed on every run to keep a single open tracking PR.\n`;

    // Create or update PR
    if (prs.length > 0) {
        const pr = prs[0];
        console.log(`Updating existing PR #${pr.number}`);
        await gh(`/pulls/${pr.number}`, {
            method: "PATCH",
            body: JSON.stringify({ title: prTitle, body: prBody }),
        });
        console.log(`Updated PR #${pr.number}`);
    } else {
        console.log("Creating a new PR");
        const created = await gh<{ number: number }>(`/pulls`, {
            method: "POST",
            body: JSON.stringify({
                title: prTitle,
                head: BRANCH,
                base: defaultBranch,
                body: prBody,
                maintainer_can_modify: true,
                draft: false,
            }),
        });
        console.log(`Created PR #${created.number}`);
    }
}

main().catch((e) => {
    console.error(e);
    process.exit(1);
});
