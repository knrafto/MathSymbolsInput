# Development

The project has the following targets:
* MathSymbolsInput: the core input method, installed in `/Library/Input Methods`
* MathSymbolsPreferences: a GUI app for the "Preferences..." menu, installed in
  `/Applications`
* InstallerActivatePane: an installer plugin that activates the input method
  during installation

These are configured to build into the `build/` directory. The preferences app
can be run normally from Xcode during development. The others require a bit more
work to test.

## Testing the input method

To update the input method with your local debug build, first switch to a
different input method, run `./install_dev_version.sh`, and switch back. To view
`NSLog` output, open Console.app and search for MathSymbolsInput.

Sometimes running `./install_dev_version.sh` too many times will cause the OS to
report that the input method has crashed, and will refuse to restart it. When
this happens, you must log out and log back in. I'm not sure how to prevent
this. 

## Testing the installer

Run `./build_package.sh` to create a release build and package it into a `.pkg`
file for the macOS installer.

To perform an installation, first `rm -rf build` to delete the build directory
(otherwise the installer will try to overwrite the apps there instead of
installing into the correct locations) and `open MathSymbolsInputInstaller.pkg`.

## Reference documentation

* Carbon header file: https://github.com/phracker/MacOSX-SDKs/blob/master/MacOSX10.6.sdk/System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/HIToolbox.framework/Versions/A/Headers/TextInputSources.h
* Apple tech note on input methods: http://mirror.informatimago.com/next/developer.apple.com/technotes/tn2005/tn2128.html
* InputMethodKit documentation: https://developer.apple.com/documentation/inputmethodkit
* Cocoa text editing overview: https://developer.apple.com/library/archive/documentation/TextFonts/Conceptual/CocoaTextArchitecture/TextEditing/TextEditing.html
