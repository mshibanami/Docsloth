<p align="center">
    <img src="logo.png" alt="Docsloth Logo" width="300" />
</p>

# Docsloth 🦥

[![Test](https://github.com/mshibanami/Docsloth/actions/workflows/test.yml/badge.svg)](https://github.com/mshibanami/Docsloth/actions/workflows/test.yml)
[![Benchmark](https://github.com/mshibanami/Docsloth/actions/workflows/benchmark.yml/badge.svg)](https://github.com/mshibanami/Docsloth/actions/workflows/benchmark.yml)

**Docsloth** is a Swift wrapper for [markdown-it](https://github.com/markdown-it/markdown-it) and [Asciidoctor.js](https://github.com/asciidoctor/asciidoctor.js), which convert Markdown and AsciiDoc into HTML and support a wide range of features and plugins.

In additions, Docsloth's UI module provides a convenient way to display rendered HTML content, which is a `WKWebView` wrapper and fully supports text selection and copy & paste. Plus, you can easily customize the appearance using CSS.

## Docsloth is slow & memory-consuming

Docsloth is slow because it's a Swift wrapper around JavaScript libraries. It is much slower than native Swift libraries such as [Ink](https://github.com/JohnSundell/Ink) or [swift-markdown](https://github.com/swiftlang/swift-markdown). It also consumes more memory. You can find the benchmark results [here](https://github.com/mshibanami/Docsloth/actions/workflows/benchmark.yml).

The main advantage of Docsloth is that it is powered by well-maintained JavaScript libraries, which offer a rich set of features and are supported by large communities. We also provide a way to configure these libraries and their plugins directly through Swift.

Therefore, Docsloth is suitable for apps that require advanced rendering features but are not very sensitive to performance.

## Getting Started

This is how to convert Markdown to HTML:

```swift
import DocslothMarkdownItGFMCJKFriendly

let markdownIt = MarkdownIt()
try await markdownIt.setup()
let html = markdownIt.convertToHTML("# Hello, Docsloth!")
print(html) // <h1>Hello, Docsloth!</h1>
```

You can also customize options and plugins:

```swift
import DocslothMarkdownItGFMCJKFriendly

let markdownIt = MarkdownIt(options: MarkdownItOptions(
    base: [
        "linkify": false,
        "breaks": true,
    ],
    plugins: [
        // Options for `markdown-it-task-checkbox`
        .githubAlerts: [
            "matchCaseSensitive": true
        ]
    ],
    // This disables the emoji plugin
    disablePlugins: [.emoji]
))
```

This is how you can convert AsciiDoc to HTML:

```swift
import DocslothAsciidoctor

let asciidoctor = DocslothAsciidoctor()
try await asciidoctor.setup()
let html = asciidoctor.convertToHTML("= Hello, Docsloth!")

print(html) // <h1>Hello, Docsloth!</h1>
```

You can display the rendered HTML content in SwiftUI using `DocslothView`:

```swift
import SwiftUI
import DocslothUI
import DocslothMarkdownItGFMCJKFriendly

struct ContentView: View {
    @State private var markdownIt = MarkdownIt()

    var body: some View {
        DocslothView(
            source: "# Hello, Docsloth!",
            converter: markdownIt
        )
        .docslothStyle(DocslothGitHubStyle())
        .task {
            try? await markdownIt.setup()
        }
    }
}
```

You can also find working examples in [Examples](Examples).

## Modules

Docsloth consists of many modules so you don't need to import unnecessary ones. These are base modules:

* **DocslothUI:** Provides the `DocslothView` for SwiftUI integration. This doesn't include any styles by default, so you can customize the appearance using CSS. If you want a pre-defined style, you can import `DocslothGitHubStyle` to use.
* **DocslothGitHubStyle:** A pre-defined style for the `DocslothView` that is similar to GitHub's style.

Also, there are several converter modules:

* **[markdown-it](https://github.com/markdown-it/markdown-it)**
    * **DocslothMarkdownIt:** A module for rendering Markdown without any additional plugins.
    * **DocslothMarkdownItGFM:** A module for rendering GitHub's GFM with these plugins:
        * [markdown-it-emoji](https://www.npmjs.com/package/markdown-it-emoji)
        * [markdown-it-footnote](https://www.npmjs.com/package/markdown-it-footnote)
        * [markdown-it-github-alerts](https://www.npmjs.com/package/markdown-it-github-alerts)
        * [markdown-it-task-checkbox](https://www.npmjs.com/package/markdown-it-task-checkbox)
        * [@mshibanami-org/markdown-it-sanitize-html](https://www.npmjs.com/package/@mshibanami-org/markdown-it-sanitize-html)
    * **DocslothMarkdownItGFMCJKFriendly:** A module for rendering GFM with improved support for CJK characters. This uses the same plugins as `DocslothMarkdownItGFM` plus:
        * [markdown-it-cjk-friendly](https://www.npmjs.com/package/markdown-it-cjk-friendly)
* **[Asciidoctor.js](https://github.com/asciidoctor/asciidoctor.js)**
    * **DocslothAsciidoctor:** A module for rendering AsciiDoc content without any additional plugins.

## Q&A

### Q. How should I set up `MarkdownIt` / `Asciidoctor`?

Both `MarkdownIt` and `Asciidoctor` keeps JavaScriptCore's JSContext in memory, and once you call `setup()`, you can use it everywhere in your app. So, you should create a single instance and reuse it.

### Q. What does "GFM" mean in Docsloth?

In Docsloth, "GFM" refers to **GitHub's** GitHub Flavored Markdown, not [cmark-gfm](https://github.com/github/cmark-gfm). As of 2025, cmark-gfm hasn't been updated since 2023 and it doesn't support some features GitHub has, such as [Alerts](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#alerts). Docsloth rather tries to follow what GitHub actually supports.

Also, we focus on GFM which is applied to rendering Markdown files such as `README.md` on github.com. So, some features may not be available in Docsloth, such as [mention](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#mentioning-people-and-teams).

### Q. What is "CJK Friendly"?

It means that the converter uses [a plugin](https://github.com/tats-u/markdown-cjk-friendly) to handle CJK (Chinese, Japanese, Korean) languages more effectively. This is especially useful for texts generated by LLMs, which often lack spaces between words in CJK languages.

### Q. How can I customize the appearance of `DocslothView`?

You can simply copy & paste our [GitHub style](Sources/GitHubStyle) to your project and modify it as you like. Then, load your style to `DocslothView`:

```swift
DocslothView(...)
    .docslothStyle(yourCustomTheme)
```

## License

Docsloth's own code is licensed under the MIT License. See [LICENSE.txt](LICENSE.txt) for details.

The licenses of each port's dependencies are provided in JSON format in [js/dist](js/dist).

We only use dependencies with permissive licenses, such as MIT, Apache License 2.0, BSD, and ISC.
