# Development

The project has the following targets:
* MathSymbolsInput: the core input method, installed in `/Library/Input Methods`
* MathSymbolsInputPreferences: a GUI app for the "Preferences..." menu, installed in
  `/Applications`
* activate: a command-line tool to enable and select the input method after an install
  or upgrade

These are configured to build into the `build/` directory. The preferences app
can be run normally from Xcode during development. The others require a bit more
work to test.

## Testing the input method

To update the input method with your local debug build, first switch to a
different input method, run `./install.sh`, and switch back. To view
`NSLog` output, open Console.app and search for "Math Symbols Input".

## Testing the installer

Run `./package` to create a release build and package it into a `.pkg`
file for the macOS installer. Run `open MathSymbolsInput.pkg` to perform an install.

## Reference documentation

* Carbon header file: https://github.com/phracker/MacOSX-SDKs/blob/master/MacOSX10.6.sdk/System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/HIToolbox.framework/Versions/A/Headers/TextInputSources.h
* Apple tech note on input methods: http://mirror.informatimago.com/next/developer.apple.com/technotes/tn2005/tn2128.html
* InputMethodKit documentation: https://developer.apple.com/documentation/inputmethodkit
* Cocoa text editing overview: https://developer.apple.com/library/archive/documentation/TextFonts/Conceptual/CocoaTextArchitecture/TextEditing/TextEditing.html

## Text format

The text format is a line-oriented UTF-8 text file, with lines ending in either `\r\n` or `\n`. Each line is either:

* Empty
* A comment line, beginning with `#`
* A command and a replacement, separated by a single space.

Commands:
* must start with `\`
* cannot contain space, `\r`, or `\n` characters
* are at most 1000 Unicode code points long.

Replacements:
* cannot contain `\r` or `\n` characters (but they can contain space characters)
* are at most 1000 Unicode code points long.
