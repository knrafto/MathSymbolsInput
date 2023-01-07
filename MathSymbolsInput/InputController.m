#import "InputController.h"

#import "Commands.h"

#ifdef DEBUG
#define DLog(...) NSLog(__VA_ARGS__)
#else
#define DLog(...)
#endif

// Preferences app name.
static NSString *kPreferencesAppBundleIdentifier = @"com.mathsymbolsinput.MathSymbolsInputPreferences";
// NSUserDefaults key for the preferences tab.
static NSString *kPreferencesTabKey = @"PreferencesTab";

// Maximum number of characters that could be returned from UCKeyTranslate.
const int kUCKeyTranslateBufferLength = 255;

// See IMKInputController.h for documentation of the IMKServerInput protocol.
@implementation InputController {
  // Buffer containing text that the user has input so far in the current
  // composition session.
  NSMutableString *compositionBuffer;

  // Dead key state for reading keyboard input.
  UInt32 deadKeyState;

  // Last dead key pressed, or empty string if the last key was not a dead key.
  NSString *lastDeadKey;

  // Menu displayed in the menu bar.
  NSMenu *menu;
}

// Initializes the input controller.
- (id)initWithServer:(IMKServer *)server delegate:(id)delegate client:(id)inputClient {
  self = [super initWithServer:server delegate:delegate client:inputClient];
  if (self) {
    compositionBuffer = [[NSMutableString alloc] init];
    deadKeyState = 0;
    lastDeadKey = @"";

    menu = [[NSMenu alloc] init];
    [menu addItemWithTitle:@"View Default Commands..." action:@selector(showDefaultCommands:) keyEquivalent:@""];
    [menu addItemWithTitle:@"Edit Custom Commands..." action:@selector(showCustomCommands:) keyEquivalent:@""];
    [menu addItemWithTitle:@"About" action:@selector(showAbout:) keyEquivalent:@""];
  }
  return self;
}

// Update the client's state match the composition plus any dead keys. This
// must be called whenever the composition or dead key state changes.
- (void)updateMarkedText {
  NSString *markedText = [compositionBuffer stringByAppendingString:lastDeadKey];
  // Seems like using an NSAttributedString for setMarkedText is necessary to
  // get the cursor to appear at the end of the marked text instead of selecting
  // the whole range.
  NSDictionary *attrs = [self markForStyle:kTSMHiliteSelectedRawText
                                   atRange:NSMakeRange(0, [markedText length])];
  NSAttributedString *attrString =
      [[NSAttributedString alloc] initWithString:markedText attributes:attrs];
  [[self client] setMarkedText:attrString
                selectionRange:NSMakeRange([markedText length], 0)
              replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
}

// Sends text for the client to insert.
- (void)insertText:(NSString *)string {
  if ([string length] > 0) {
    [[self client] insertText:string replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
  }
}

// Accepts the currently-chosen replacement.
- (void)accept {
  NSString *replacement = findReplacement(compositionBuffer);
  NSString *acceptedString = replacement != nil ? replacement : compositionBuffer;
  [self insertText:acceptedString];
  [compositionBuffer setString:@""];
  [self updateMarkedText];
}

// Inserts the contents of the buffer without making a replacement, returning to
// an inactive state.
- (void)deactivate {
  [self insertText:compositionBuffer];

  [compositionBuffer setString:@""];
  deadKeyState = 0;
  lastDeadKey = @"";

  [self updateMarkedText];
}

// Returns a Unicode representation of a keydown event, or nil if the event
// should not be handled by us.
- (NSString *)readCharacters:(NSEvent *)event {
  if ([event type] != NSEventTypeKeyDown) {
    return nil;
  }

  unsigned short keyCode = [event keyCode];
  NSEventModifierFlags modifierFlags = [event modifierFlags];
  // Skip events with control or command held, since these are probably
  // keyboard shortcuts.
  if (modifierFlags & NSEventModifierFlagControl ||
      modifierFlags & NSEventModifierFlagCommand) {
    return nil;
  }

  TISInputSourceRef inputSource = TISCopyCurrentASCIICapableKeyboardLayoutInputSource();
  CFDataRef layoutData = (CFDataRef) TISGetInputSourceProperty(inputSource, kTISPropertyUnicodeKeyLayoutData);
  if (layoutData == nil) {
    NSLog(@"No keyboard layout data");
    return nil;
  }
  const UCKeyboardLayout *keyboardLayout = (const UCKeyboardLayout *) CFDataGetBytePtr(layoutData);
  UInt32 keyboardType = (UInt32) CGEventGetIntegerValueField([event CGEvent], kCGKeyboardEventKeyboardType);

  int unicodeModifiers = 0;
  if (modifierFlags & NSEventModifierFlagShift) unicodeModifiers |= shiftKey;
  if (modifierFlags & NSEventModifierFlagCapsLock) unicodeModifiers |= alphaLock;
  if (modifierFlags & NSEventModifierFlagOption) unicodeModifiers |= optionKey;
  UInt32 modifierKeyState = (unicodeModifiers >> 8) & 0xFF;

  UniChar buffer[kUCKeyTranslateBufferLength];
  UniCharCount resultLength;
  OSStatus status = UCKeyTranslate(keyboardLayout,
                                   keyCode,
                                   kUCKeyActionDown,
                                   modifierKeyState,
                                   keyboardType,
                                   0,
                                   &deadKeyState,
                                   kUCKeyTranslateBufferLength,
                                   &resultLength,
                                   buffer);

  if (status != noErr) {
    NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
    NSLog(@"Could not translate key: %@", [error localizedDescription]);
    return nil;
  }

  NSString *string = [[NSString alloc] initWithCharacters:buffer length:resultLength];

  // It appears that the low bytes of deadKeyState is the current state, while
  // the high bytes are the previous state. So if the low bytes are nonzero,
  // we're currently in a dead key state. We call UCKeyTranslate again with
  // dead key processing turned off to find out what the dead key was.
  if ((deadKeyState & 0xFFFF) != 0) {
    UInt32 unusedDeadKeyState = 0;
    status = UCKeyTranslate(keyboardLayout,
                            keyCode,
                            kUCKeyActionDown,
                            modifierKeyState,
                            keyboardType,
                            kUCKeyTranslateNoDeadKeysMask,
                            &unusedDeadKeyState,
                            kUCKeyTranslateBufferLength,
                            &resultLength,
                            buffer);

    if (status != noErr) {
      NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
      NSLog(@"Could not translate dead key: %@", [error localizedDescription]);
      return nil;
    }

    lastDeadKey = [[NSString alloc] initWithCharacters:buffer length:resultLength];
  } else {
    lastDeadKey = @"";
  }

  DLog(@"readCharacters string:%@ deadKeyState:0x%x lastDeadKey:%@", string, deadKeyState, lastDeadKey);
  return string;
}

// Called by InputMethodKit on keydown events. This method should return YES if
// we've handled the event, and NO if the event should be passed to the client
// instead. We ensure that the composition is inactive before passing any events
// on to the client to prevent surprising behavior.
- (BOOL)handleEvent:(NSEvent *)event client:(id)sender {
  DLog(@"handleEvent event:(%@) client:%@", [event debugDescription], [[self client] bundleIdentifier]);
  NSString* string = [self readCharacters:event];
  if (string == nil) {
    [self deactivate];
    return NO;
  }

  // Keyboard layouts use ASCII control codes to represent special keys
  // like backspace or the arrow keys. They could be preceded by normal text
  // if the user presses a dead key before the special key. Anecdotally it
  // seems like it's not allowed to have a keyboard layout that emits more than
  // one control character, or a control character in the middle of a string.
  //
  // We also treat backslash and space as "control codes" here since they are
  // also treated specially by the input method. This does mean that these
  // characters would not be handled if they're in the middle of the input
  // string, but it's not clear what we should do in that case anyway.
  unichar controlCode = 0;
  NSUInteger length = [string length];
  if (length > 0) {
    unichar c = [string characterAtIndex:(length - 1)];
    if (c <= 0x20 || /* C0 control codes and space */
        c == 0x5c || /* backslash */
        (c >= 0x7f && c <= 0x9f) /* C1 control codes */) {
      controlCode = c;
      string = [string substringToIndex:(length - 1)];
    }
  }

  if ([compositionBuffer length] == 0) {  // no active composition
    [self insertText:string];
    [self updateMarkedText];

    // normal typing
    if (controlCode == 0) {
      return YES;
    }
    // backslash: start a new composition
    if (controlCode == '\\') {
      [compositionBuffer appendString:@"\\"];
      [self updateMarkedText];
      return YES;
    }
  } else {  // active composition
    [compositionBuffer appendString:string];
    [self updateMarkedText];

    // normal typing
    if (controlCode == 0) {
      return YES;
    }
    // enter or tab: accept current composition
    if (controlCode == '\r' || controlCode == '\t') {
      [self accept];
      return YES;
    }
    // space: accept current composition and insert space
    if (controlCode == ' ') {
      [self accept];
      [self insertText:@" "];
      return YES;
    }
    // backslash: accept current composition and start a new one
    if (controlCode == '\\') {
      [self accept];
      [compositionBuffer appendString:@"\\"];
      [self updateMarkedText];
      return YES;
    }
    // backspace: remove last grapheme cluster from composition
    if (controlCode == 0x08) {
      NSRange range = [compositionBuffer rangeOfComposedCharacterSequenceAtIndex:[compositionBuffer length] - 1];
      [compositionBuffer deleteCharactersInRange:range];
      [self updateMarkedText];
      return YES;
    }
    // escape: deactivate
    if (controlCode == 0x1b) {
      [self deactivate];
      return YES;
    }
  }

  // For all other cases, deactivate and let the client handle the event.
  [self deactivate];
  return NO;
}

// Called by InputMethodKit when the client wants to end composition immediately
// (e.g. the user selected a new input method, or clicked outside of the marked
// text).
- (void)commitComposition:(id)sender {
  DLog(@"commitComposition client:%@", [[self client] bundleIdentifier]);
  [self deactivate];
}

// Called by InputMethodKit when the client gains focus.
- (void)activateServer:(id)sender {
  DLog(@"activateServer client:%@", [[self client] bundleIdentifier]);
}

// Called by InputMethodKit when the client loses focus.
- (void)deactivateServer:(id)sender {
  DLog(@"deactivateServer client:%@", [[self client] bundleIdentifier]);
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
