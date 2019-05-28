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
  NSMutableString* _compositionBuffer;
}

// Gets the current composition buffer, allocating if necessary.
- (NSMutableString*)compositionBuffer {
  if (_compositionBuffer == nil) {
    _compositionBuffer = [[NSMutableString alloc] init];
  }
  return _compositionBuffer;
}

// Returns whether there is an active composition session.
- (BOOL)isActive {
  return [[self compositionBuffer] length] > 0;
}

// Appends to the current composition, updating to marked text.
- (void)appendComposition:(NSString*)string client:(id)sender {
  NSMutableString* compositionBuffer = [self compositionBuffer];
  [compositionBuffer appendString:string];

  // Seems like using an NSAttributedString for setMarkedText is necessary to
  // get the cursor to appear at the end of the marked text instead of selecting
  // the whole range.
  NSDictionary* attrs =
      [self markForStyle:kTSMHiliteSelectedRawText
                 atRange:NSMakeRange(0, [compositionBuffer length])];
  NSAttributedString* attrString =
      [[NSAttributedString alloc] initWithString:compositionBuffer
                                      attributes:attrs];
  [sender setMarkedText:attrString
         selectionRange:NSMakeRange([compositionBuffer length], 0)
       replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
}

// Finishes the current composition，returning to an inactive state.
- (void)deactivate:(id)sender {
  NSMutableString* compositionBuffer = [self compositionBuffer];
  [sender insertText:compositionBuffer
      replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
  [compositionBuffer setString:@""];
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
    [self appendComposition:string client:sender];
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
