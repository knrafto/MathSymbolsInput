//
//  UnicodeInputController.m
//  UnicodeInput
//
//  Created by Kyle Raftogianis on 5/28/19.
//  Copyright © 2019 Kyle Raftogianis. All rights reserved.
//

#import "UnicodeInputController.h"

// See IMKInputController.h for documentation of the IMKServerInput protocol.
@implementation UnicodeInputController {
  // Buffer containing text that the user has input so far in the current
  // composition session. We ensure that the client's marked text always
  // matches the contents.
  NSMutableString* _buffer;
}

// Gets the current composition buffer, allocating if necessary.
- (NSMutableString*)buffer {
  if (_buffer == nil) {
    _buffer = [[NSMutableString alloc] init];
  }
  return _buffer;
}

// Returns whether there is an active composition session.
- (BOOL)isActive {
  return [[self buffer] length] > 0;
}

// Update the marked text to match the contents of the buffer. This must be called whenever the buffer changes.
- (void)updateMarkedText:(id)sender {
  NSMutableString* buffer = [self buffer];
  // Seems like using an NSAttributedString for setMarkedText is necessary to
  // get the cursor to appear at the end of the marked text instead of selecting
  // the whole range.
  NSDictionary* attrs = [self markForStyle:kTSMHiliteSelectedRawText
                                   atRange:NSMakeRange(0, [buffer length])];
  NSAttributedString* attrString =
      [[NSAttributedString alloc] initWithString:buffer attributes:attrs];
  [sender setMarkedText:attrString
         selectionRange:NSMakeRange([buffer length], 0)
       replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
}

// Inserts the contents of the buffer without making a replacement, returning to an inactive state.
- (void)deactivate:(id)sender {
  NSMutableString* buffer = [self buffer];
  [sender insertText:buffer
      replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
  [buffer setString:@""];
}

// On keydown events, the system will either call inputText: (for most typed
// characters) or didCommandBySelector: (for special actions e.g. pressing
// backspace). These methods return YES if we handled the event, and NO if the
// event should be passed to the client instead. We ensure that the composition
// is inactive before passing any events on to the client to prevent surprising
// behavior.

- (BOOL)inputText:(NSString*)string client:(id)sender {
  NSLog(@"inputText:%@", string);
  if ([self isActive] || [string isEqualToString:@"\\"]) {
    [[self buffer] appendString:string];
    [self updateMarkedText:sender];
    return YES;
  }
  return NO;
}

- (BOOL)didCommandBySelector:(SEL)aSelector client:(id)sender {
  NSLog(@"didCommandBySelector:%@", NSStringFromSelector(aSelector));
  if ([self isActive] && aSelector == @selector(insertNewline:)) {
    [self deactivate:sender];
    return YES;
  }
  [self deactivate:sender];
  return NO;
}

// Called by the system when the client wants to end composition immediately
// (e.g. the user selected a new input method, or clicked outside of the marked
// text).
- (void)commitComposition:(id)sender {
  NSLog(@"commitComposition:");
  [self deactivate:sender];
}

@end
