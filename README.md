# Unicode input method

## Development

Build the Xcode project, and run `./install.sh` to copy the result to "~/Library/Input Methods".

Then log out and log back in, and add the input method in
`System Preferences > Keyboard > Input Sources`.

After making code changes, switch to different input method, wait for a little
bit, run `./install.sh`, and switch back to the Unicode input method.

Changes to cached metadata (e.g. input method icon) require you to log out and
log back in.

## Keyboard layouts

By default, macOS uses the last keyboard layout when an input method is active.
So, to use your desired keyboard layout, activate the keyboard layout first and
then the UnicodeInput input method.

## References

### Sample projects

* https://github.com/palanceli/macIMKSample (blog posts: 
  [part 1](http://palanceli.com/2017/03/05/2017/0305macOSIMKSample1/)
  [part 2](http://palanceli.com/2017/03/23/2017/0323macOSIMKSample2/)
  [part 3](http://palanceli.com/2017/03/27/2017/0327macOSIMKSample3/))
* https://github.com/pkamb/NumberInput_IMKit_Sample

### Input method documentation

* [InputMethodKit](https://developer.apple.com/documentation/inputmethodkit?language=objc)
* [Cocoa Text Editing](https://developer.apple.com/library/archive/documentation/TextFonts/Conceptual/CocoaTextArchitecture/TextEditing/TextEditing.html)
