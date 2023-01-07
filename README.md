**Math Symbols Input** is a macOS [input method](https://en.wikipedia.org/wiki/Input_method) for typing mathematical symbols with LaTeX-style commands.
It works seamlessly with any Mac app.

![Math Symbols Input Demo](demo.gif)

# Installation

The latest version is Version 1.2. To install or update Math Symbols Input:

1. Download the [installer for the latest version](https://github.com/knrafto/MathSymbolsInput/releases/latest/download/MathSymbolsInput.pkg).
2. Open the installer and continue through the installation steps.

The installer can enable the input method automatically. If you want to configure input sources, see the [macOS help page on input sources](
https://support.apple.com/guide/mac-help/type-language-mac-input-sources-mchlp1406/mac).

# Usage

Type a backslash `\` to start a command. The text should appear underlined while the command is being typed to show the input method is active. While the input method is active:

* Typing normally by pressing letters, symbols, or the backspace key will edit the command.
* **Enter** or **tab** will replace the command with its math symbol. If the command does not have an associated math symbol, the command text will be inserted verbatim instead.
* **Space** will replace the command and insert a space afterward.
* **Backslash** will replace the command and start a new command.
* **Escape** will insert the command text verbatim (e.g. if you need to type `\alpha` instead of `α`).

## Default commands

To view a searchable list of all default commands, click the Math Input Symbols `∀` icon in the menu bar and select `View Default Commands...`.
The default commands are also listed in [this text file](https://github.com/knrafto/MathSymbolsInput/blob/master/MathSymbolsInput/commands.txt).

If you think some command would be broadly usable and should be a default command, consider opening an issue or pull request.

## Custom commands

To add your own commands, click the Math Input Symbols `∀` icon in the menu bar and select `Edit Custom Commands...`.
New commands will take effect immediately.

# FAQ

## Are there Windows or Linux versions?

Not yet, but hopefully soon.

## Can I use a keyboard layout other than the US layout?

Yes, Math Symbols Input uses the last selected keyboard layout. [Dead keys](https://en.wikipedia.org/wiki/Dead_key)
will continue to work, but the macOS's press-and-hold [accent menu](https://support.apple.com/guide/mac-help/enter-characters-with-accent-marks-on-mac-mh27474/mac)
unfortunately will not.

# Inspirations

Many programming languages are capable of inputting mathematical symbols, but this is usually limited to a single app. These include:

* [Agda](https://agda.readthedocs.io/en/latest/tools/emacs-mode.html#unicode-input)
* [Julia](https://docs.julialang.org/en/v1/manual/unicode-input/)
* [Lean](https://leanprover.github.io/reference/using_lean.html#features)
