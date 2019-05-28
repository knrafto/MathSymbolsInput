# Unicode input method

## Development

By default, the project is configured to build into `/Library/Input Methods/`.
First change permissions on this directory:

```
sudo chmod 777 /Library/Input Methods
```

Then build the Xcode project, log out and log back in, and add the input method
in `System Preferences > Keyboard > Input Sources`.

After making code changes, kill the running input method `killall UnicodeInput`
so it can restart. Changes to cached metadata (e.g. input method icon) require
you to log out and log back in.
