//
//  Benchmarks.swift
//  Docsloth
//
//  Created by Manabu Nakazawa on 25/9/2025.
//

import Benchmark
import DocslothCore
import DocslothMarkdownIt
import DocslothMarkdownItGFMCJKFriendly
import Ink
import Markdown
import MarkdownKit
import SystemPackage

let benchmarks: @Sendable () -> Void = {
    Benchmark.defaultConfiguration.units = [
        .peakMemoryResident: .mega,
        .peakMemoryVirtual: .mega,
    ]

    Benchmark("DocslothMarkdownItGFMCJKFriendly with setup") { benchmark in
        let markdownIt = DocslothMarkdownItGFMCJKFriendly.MarkdownIt()
        try await markdownIt.setup()
        _ = try await markdownIt.convertToHTML(sampleMarkdown)
    }

    Benchmark("DocslothMarkdownItGFMCJKFriendly without setup") { benchmark in
        let markdownIt = DocslothMarkdownItGFMCJKFriendly.MarkdownIt()
        try await markdownIt.setup()
        benchmark.startMeasurement()
        _ = try await markdownIt.convertToHTML(sampleMarkdown)
    }

    Benchmark("DocslothMarkdownIt without setup") { benchmark in
        let markdownIt = DocslothMarkdownIt.MarkdownIt()
        try await markdownIt.setup()
        benchmark.startMeasurement()
        _ = try await markdownIt.convertToHTML(sampleMarkdown)
    }

    Benchmark("DocslothMarkdownIt with setup") { benchmark in
        let markdownIt = DocslothMarkdownIt.MarkdownIt()
        try await markdownIt.setup()
        _ = try await markdownIt.convertToHTML(sampleMarkdown)
    }

    Benchmark("SwiftMarkdown") { benchmark in
        let document = Document(parsing: sampleMarkdown)
        let html = HTMLFormatter.format(document)
    }

    Benchmark("Swift MarkdownKit") { benchmark in
        let parser = MarkdownParser.standard.parse(sampleMarkdown)
        let html = parser.string
    }

    Benchmark("Ink") { benchmark in
        let parser = Ink.MarkdownParser()
        let html = parser.html(from: sampleMarkdown)
    }
}

private let sampleMarkdown = """
# Hello, Docsloth!

This is a sample markdown document.

## Lists

- Item 1
- Item 2
- Item 3

- Nested Item
  - Subitem 1
  - Subitem 2

- [x] Completed Task
- [ ] Incomplete Task
- [ ] Another Task

<form action="/action_page.php">
  <label for="fname">First name:</label>
  <input type="text" id="fname" name="fname"><br><br>
  <label for="lname">Last name:</label>
  <input type="text" id="lname" name="lname"><br><br>
  <input type="submit" value="Submit">
</form>

## HTML Comments

↓ There was a HTML comment...

<!-- This is an HTML comment and will not be displayed in the rendered output. -->

↑ ... between these paragraphs.

## Code Example

```swift
import SwiftUI
struct ContentView: View {
    var body: some View {
        Text("Hello, World!")
    }
}
```

### Table Example

| Header 1 | Header 2 |
|----------|----------|
| Cell 1   | Cell 2   |
| Cell 3   | Cell 4   |

### Emoji Example

Here is a smiley face: :smile:
And a thumbs up: 👍

### Bold syntax in CJK text

**ハロー。**ワールド。

### Links

[Visit Docsloth](https://github.com/mshibanami/Docsloth)

Angle brackets: <https://www.example.com>

HTML tagged link: <a href="https://www.example.com">Example</a>

### Image

![Placeholder image](https://placehold.co/600x400/EEE/31343C.png)

### Inline link sample

`hello world`

### Keyboard keys

Press <kbd>Cmd</kbd> + <kbd>C</kbd> to copy.

### Quotes

> This is a blockquote.
>
> - It can contain lists
> - And other markdown elements

> Nested blockquote
>> This is a nested blockquote.
>>> Even deeper!
> Back to the first level.

### Alerts

> [!NOTE]
> Highlights information that users should take into account, even when skimming.

> [!TIP]
> Optional information to help a user be more successful.

> [!IMPORTANT]
> Crucial information necessary for users to succeed.

> [!WARNING]
> Critical content demanding immediate user attention due to potential risks.

> [!CAUTION]
> Negative potential consequences of an action.
"""
