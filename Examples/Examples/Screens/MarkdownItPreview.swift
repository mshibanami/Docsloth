//
//  ContentView.swift
//  Examples
//
//  Created by Manabu Nakazawa on 20/9/2025.
//

import DocslothAsciidoctor
import DocslothCore
import DocslothGitHubStyle
import DocslothMarkdownItGFMCJKFriendly
import DocslothUI
import SwiftUI

struct MarkdownItPreview: View {
    @State private var markdownIt = MarkdownIt()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                content
            }
            .scenePadding()
        }
        .task {
            try? await markdownIt.setup()
        }
    }
    var content: some View {
        VStack(alignment: .leading, spacing: 60) {
            DocslothView(text: sampleMarkdown, converter: markdownIt)
                .docslothStyle(DocslothGitHubStyle())

            VStack(alignment: .leading) {
                Text("Docsloth VS Text")
                    .font(.title.bold())
                TabView {
                    Tab {
                        ScrollView {
                            DocslothView(
                                text: longText,
                                converter: markdownIt,
                            )
                            .docslothStyle(DocslothGitHubStyle())
                        }
                    } label: { Text("DocslothView") }

                    Tab {
                        ScrollView {
                            Text(longText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    } label: { Text("Text") }
                }
#if canImport(UIKit)
                .background(.gray.opacity(0.3))
#endif
                .frame(height: 250)
            }
        }
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

private let longText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

#Preview {
    MarkdownItPreview()
}
