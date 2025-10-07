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

struct AsciidoctorPreview: View {
    @State private var asciidoctor = Asciidoctor()
    
    var body: some View {
        ScrollView {
            content
                .scenePadding()
        }
        .task {
            try? await asciidoctor.setup()
        }
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: 60) {
            DocslothView(text: sampleAsciiDoc, converter: asciidoctor)
                .docslothStyle(DocslothGitHubStyle())

            VStack(alignment: .leading) {
                Text("Docsloth VS Text")
                    .font(.title.bold())
                TabView {
                    Tab {
                        ScrollView {
                            DocslothView(
                                text: longText,
                                converter: asciidoctor,
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

private let sampleAsciiDoc = """
= AsciiDoc Cheat Sheet
:toc: left
:icons: font
:sectnums:
:source-highlighter: highlightjs
:experimental:

// This cheat sheet summarizes major AsciiDoc syntax with examples.
// Each block can be copy-pasted and tested.

== Headings

= Level 1
== Level 2
=== Level 3
==== Level 4
===== Level 5

[#custom-id]
== Heading with ID

== Paragraphs, Line Breaks, Horizontal Rules

Normal paragraph is separated by a blank line.

Force line break with `+` +
This continues on the next line.

'''
Horizontal rule

== Inline Formatting

*bold*  _italic_  *_bold italic_*
`monospace`  +passthrough+  #mark#  [small]#small text#
^superscript^  ~subscript~

[.lead]#Lead paragraph style#

== Quotes and Footnotes

[quote, Aristotle]
____
Quality is not an act, it is a habit.
____

[verse, Author, Work]
____
Poems or lyrics go here.
____

This is a footnote footnote:[This is the footnote text].
Another reference footnoteref:[fn1, reused note].

== Links and Images

Auto link: https://asciidoctor.org

https://asciidoctor.org[AsciiDoctor link]

Cross reference: <<custom-id, Go to custom heading>>

image::https://placehold.co/600x400/EEE/31343C.png[Title, width=400, alt=Alt text]

== Lists

=== Bulleted
* Apple
* Orange
** Navel
*** Sub-level

- Hyphen also works
- Checklist
* [x] Done
* [ ] Todo

=== Numbered
. First
. Second
.. Sub 1
.. Sub 2

=== Definition
Term:: Definition
API:: Application Programming Interface

== Code / Source Blocks

----
echo "plain text"
----

[source,javascript]
----
function hello() {
  console.log("Hello, AsciiDoc!");
}
----

```ruby
puts "Hello"
```
"""

private let longText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

#Preview {
    AsciidoctorPreview()
}
