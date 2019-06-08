# Unicode input method

## Development

By default, the project is configured to build into `/Library/Input Methods/`.
First change permissions on this directory:

```
sudo chmod 777 "/Library/Input Methods"
```

Then build the Xcode project, log out and log back in, and add the input method
in `System Preferences > Keyboard > Input Sources`.

After making code changes, switch to different input method, kill the running
input method `killall UnicodeInput`, wait a little bit, and switch back to the
Unicode input method. Changes to cached metadata (e.g. input method icon)
require you to log out and log back in.

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
