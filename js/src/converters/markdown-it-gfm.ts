import { MarkdownItPluginName, setupMarkdownIt, type MarkdownItOptions } from "@/types/markdown-it-options";
import MarkdownIt from "markdown-it";
import FootnotePlugin from "markdown-it-footnote";
import MarkdownItGitHubAlerts from "markdown-it-github-alerts";
import TaskCheckbox from "markdown-it-task-checkbox";
import { full as EmojiPlugin } from "markdown-it-emoji";
import SanitizeHtml from "@mshibanami-org/markdown-it-sanitize-html";

const pluginMap = {
    [MarkdownItPluginName.SanitizeHtml]: SanitizeHtml,
    [MarkdownItPluginName.Footnote]: FootnotePlugin,
    [MarkdownItPluginName.GitHubAlerts]: MarkdownItGitHubAlerts,
    [MarkdownItPluginName.TaskCheckbox]: TaskCheckbox,
    [MarkdownItPluginName.Emoji]: EmojiPlugin,
};
const markdownIt = MarkdownIt();
var markdownItOptions: MarkdownItOptions | undefined;

export function setup(options: MarkdownItOptions) {
    if (!options) {
        throw new Error("markdown-it options are required.");
    }
    markdownItOptions = options;
    setupMarkdownIt(markdownIt, markdownItOptions, pluginMap);
}

export function convertMarkdownToHtml(markdown: string): string {
    if (!markdownItOptions) {
        throw new Error("markdown-it options not initialized. Call setup() first.");
    }
    var html = markdownIt.render(markdown);
    return html;
}
