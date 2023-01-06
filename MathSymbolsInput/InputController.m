#import "InputController.h"

#import "Commands.h"

// Preferences app name.
static NSString *kPreferencesAppBundleIdentifier = @"com.mathsymbolsinput.MathSymbolsInputPreferences";
// NSUserDefaults key for the preferences tab.
static NSString *kPreferencesTabKey = @"PreferencesTab";

// See IMKInputController.h for documentation of the IMKServerInput protocol.
@implementation InputController {
  // Buffer containing text that the user has input so far in the current
  // composition session. We ensure that the client's marked text always
  // matches the contents.
  NSMutableString *compositionBuffer;

  // Menu displayed in the menu bar.
  NSMenu *menu;
}

// Initializes the input controller.
- (id)initWithServer:(IMKServer *)server delegate:(id)delegate client:(id)inputClient {
  self = [super initWithServer:server delegate:delegate client:inputClient];
  if (self) {
    compositionBuffer = [[NSMutableString alloc] init];

    menu = [[NSMenu alloc] init];
    [menu addItemWithTitle:@"View Default Commands..." action:@selector(showDefaultCommands:) keyEquivalent:@""];
    [menu addItemWithTitle:@"Edit Custom Commands..." action:@selector(showCustomCommands:) keyEquivalent:@""];
    [menu addItemWithTitle:@"About" action:@selector(showAbout:) keyEquivalent:@""];
  }
  return self;
}

// Returns whether there is an active composition session.
- (BOOL)isActive {
  return [compositionBuffer length] > 0;
}

// Update the client's state match the contents of the buffer. This must be
// called whenever the buffer changes.
- (void)bufferChanged {
  // Seems like using an NSAttributedString for setMarkedText is necessary to
  // get the cursor to appear at the end of the marked text instead of selecting
  // the whole range.
  NSDictionary *attrs = [self markForStyle:kTSMHiliteSelectedRawText
                                   atRange:NSMakeRange(0, [compositionBuffer length])];
  NSAttributedString *attrString =
      [[NSAttributedString alloc] initWithString:compositionBuffer attributes:attrs];
  [[self client] setMarkedText:attrString
                selectionRange:NSMakeRange([compositionBuffer length], 0)
              replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
}

// Accepts the currently-chosen replacement.
- (void)accept {
  NSString *replacement = findReplacement(compositionBuffer);
  NSString *acceptedString = replacement != nil ? replacement : compositionBuffer;
  [[self client] insertText:acceptedString
           replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
  [compositionBuffer setString:@""];
  [self bufferChanged];
}

// Inserts the contents of the buffer without making a replacement, returning to
// an inactive state.
- (void)deactivate {
  [[self client] insertText:compositionBuffer
           replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
  [compositionBuffer setString:@""];
  [self bufferChanged];
}

// On keydown events, the system will either call inputText: (for most typed
// characters) or didCommandBySelector: (for special actions e.g. pressing
// backspace). These methods return YES if we handled the event, and NO if the
// event should be passed to the client instead. We ensure that the composition
// is inactive before passing any events on to the client to prevent surprising
// behavior.

// Handles the following events:
//   * backslash: accept current selection, start new composition
//   * space (if active): accept current selection, insert space
//   * all other characters (if active): append to buffer
- (BOOL)inputText:(NSString*)string client:(id)sender {
  if ([string isEqualToString:@"\\"]) {
    [self accept];
    [compositionBuffer appendString:string];
    [self bufferChanged];
    return YES;
  } else if ([self isActive] && [string isEqualToString:@" "]) {
    [self accept];
    return NO;
  } else if ([self isActive]) {
    [compositionBuffer appendString:string];
    [self bufferChanged];
    return YES;
  }
  return NO;
}

// Handles the following events:
//   newline: accept
//   tab: accept
//   backspace: remove last character
//   escape: deactivate (insert composition as-is)
//   arrow keys (while candidates window is open): move candidate selection
- (BOOL)didCommandBySelector:(SEL)aSelector client:(id)sender {
  if ([self isActive]) {
    if (aSelector == @selector(insertNewline:) ||
        aSelector == @selector(insertTab:)) {
      [self accept];
      return YES;
    } else if (aSelector == @selector(deleteBackward:)) {
      [compositionBuffer deleteCharactersInRange:NSMakeRange([compositionBuffer length] - 1, 1)];
      [self bufferChanged];
      return YES;
    } else if (aSelector == @selector(cancelOperation:)) {
      [self deactivate];
      return YES;
    }
  }
  [self deactivate];
  return NO;
}

// Called by the system when the client wants to end composition immediately
// (e.g. the user selected a new input method, or clicked outside of the marked
// text).
- (void)commitComposition:(id)sender {
  [self deactivate];
}

// Called by InputMethodKit to display a menu in the menu bar.
- (NSMenu *)menu {
  return menu;
}

// Opens the preferences app the the given tab, which is communicated to the
// preferences app via NSUserDefaults.
- (void)openPreferences:(NSString *)tabId {
  [[NSUserDefaults standardUserDefaults] setObject:tabId forKey:kPreferencesTabKey];
  NSURL *url = [[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:kPreferencesAppBundleIdentifier];
  if (url == nil) {
    NSLog(@"Could not find preferences application with bundle id %@", kPreferencesAppBundleIdentifier);
    return;
  }
  NSLog(@"Opening preferences tab %@ with URL: %@", tabId, [url absoluteString]);
  [[NSWorkspace sharedWorkspace] openURL:url];
}

- (void)showDefaultCommands:(id)sender {
  [self openPreferences:@"default-commands"];
}

- (void)showCustomCommands:(id)sender {
  [self openPreferences:@"custom-commands"];
}

- (void)showAbout:(id)sender {
  [self openPreferences:@"about"];
}

@end
