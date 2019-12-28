# Unicode input method

## Development

Build the Xcode project, and run `./install.sh`, copy the result to "~/Library/Input Methods",
and add the "Unicode Input" input method in `System Preferences > Keyboard > Input Sources`.
You may have to log out and log back in for the input method to show up.

After making code changes, switch to different input method, wait for a little
bit, run `./install.sh`, and switch back to the Unicode input method.

## Keyboard layouts

By default, macOS uses the last keyboard layout when an input method is active.
So, to use your desired keyboard layout, activate the keyboard layout first and
then the UnicodeInput input method.
