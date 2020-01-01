Math Symbols Input is a macOS [input method](https://en.wikipedia.org/wiki/Input_method) for typing mathematical symbols with LaTeX-style commands.

![Math Symbols Input Demo](demo.gif)

# Installation

The latest version is Version 0.9. To install or update Math Symbols Input:

1. [Click here to download the installer for the latest version.](https://github.com/knrafto/MathSymbolsInput/releases/download/v0.9/MathSymbolsInput.pkg)
2. Double-click to open the installer and continue through the installation steps.

The installer can enable the input method automatically. To configure input sources, see the [macOS help page on input sources](
https://support.apple.com/guide/mac-help/type-language-mac-input-sources-mchlp1406/mac).

# Usage

Type a backslash to start a command. The text should appear underlined to show the input method is active.

when active:
backslash inserts, reactivates with backslash
space: automatically enters symbol, inserts space
newline: enters symbol
escape: enters verbatim
most other actions (ctrl-c, use mouse, paste, arrow keys, undo) enters verbatim and then sends original command

## Default commands

See text file
See preferences

## Custom commands

See preferences
If you think your commands would be broadly usable, consider opening an issue or pull request.

# FAQ

Does this work with a custom keyboard layout?

Yes, by default, macOS uses the last used keyboard layout when an input method is active.

Are there Windows or Linux versions?

Not yet. Hopefully soon.

# Inspirations

Many languages have functionality to type mathematical symbols, including:

* Agda https://github.com/agda/agda/blob/master/src/data/emacs-mode/agda-input.el#L196
* Julia https://docs.julialang.org/en/v1/manual/unicode-input/
* Lean https://github.com/leanprover/vscode-lean/blob/99e753c8bfa12136c6e94bcdf358ad53f5e9731c/translations.json

However, these are usually limited to a single app. By using an input method integrated into the OS, we can type math symbols into any app: email, private notes, documents, and messages.
