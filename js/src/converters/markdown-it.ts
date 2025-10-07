import { setupMarkdownIt, type MarkdownItOptions } from "@/types/markdown-it-options";
import MarkdownIt from "markdown-it";

const markdownIt = MarkdownIt();
var markdownItOptions: MarkdownItOptions | undefined;

export function setup(options: MarkdownItOptions) {
    if (!options) {
        throw new Error("markdown-it options are required.");
    }
    markdownItOptions = options;
    setupMarkdownIt(markdownIt, markdownItOptions, {});
}

export function convertMarkdownToHtml(markdown: string): string {
    if (!markdownItOptions) {
        throw new Error("markdown-it options not initialized. Call setup() first.");
    }
    var html = markdownIt.render(markdown);
    return html;
}
