import type MarkdownIt from "markdown-it";
import type { Options } from "markdown-it";
export interface MarkdownItOptions {
    "base"?: Options;
    "plugins"?: {
        [MarkdownItPluginName.SanitizeHtml]?: { [key: string]: any };
        [MarkdownItPluginName.CjkFriendly]?: { [key: string]: any };
        [MarkdownItPluginName.Emoji]?: { [key: string]: any };
        [MarkdownItPluginName.Footnote]?: { [key: string]: any };
        [MarkdownItPluginName.GitHubAlerts]?: { [key: string]: any };
        [MarkdownItPluginName.TaskCheckbox]?: { [key: string]: any };
    };
    "disabledPlugins"?: MarkdownItPluginName[];
}

export function setupMarkdownIt(markdownIt: MarkdownIt, options: MarkdownItOptions, pluginMap: Partial<Record<MarkdownItPluginName, any>>) {
    if (options.base) {
        markdownIt.set(options.base);
    }
    const plugins = options.plugins ?? {};
    const disabledPlugins = options.disabledPlugins ?? [];
    for (const pluginName of Object.keys(pluginMap) as MarkdownItPluginName[]) {
        if (!disabledPlugins.includes(pluginName)) {
            const plugin = pluginMap[pluginName];
            markdownIt.use(plugin, plugins[pluginName as keyof typeof plugins]);
        }
    }
}

export const MarkdownItPluginName = {
    SanitizeHtml: "markdown-it-sanitize-html",
    CjkFriendly: "markdown-it-cjk-friendly",
    Emoji: "markdown-it-emoji",
    Footnote: "markdown-it-footnote",
    GitHubAlerts: "markdown-it-github-alerts",
    TaskCheckbox: "markdown-it-task-checkbox",
} as const;

export type MarkdownItPluginName = typeof MarkdownItPluginName[keyof typeof MarkdownItPluginName];
