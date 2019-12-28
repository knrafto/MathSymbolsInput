# Unicode input method

## Development

To update the input method with your local debug build

1. Remove the "Unicode Input" input method in `System Preferences > Keyboard > Input Sources`.
1. Run `./install.sh` to copy the debug build to `~/Library/Input Methods` and kill the previous version.
1. Add the "Unicode Input" input method again in `System Preferences > Keyboard > Input Sources`.

## Keyboard layouts

By default, macOS uses the last keyboard layout when an input method is active.
So, to use your desired keyboard layout, activate the keyboard layout first and
then the UnicodeInput input method.
