# Development

The project has the following targets:
* MathSymbolsInput: the core input method, installed in `/Library/Input Methods`
* MathSymbolsInputPreferences: a GUI app for the "Preferences..." menu, installed in
  `/Applications`
* InstallerActivatePane: an installer plugin that activates the input method
  during installation

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
