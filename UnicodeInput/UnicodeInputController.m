//
//  UnicodeInputController.m
//  UnicodeInput
//
//  Created by Kyle Raftogianis on 5/28/19.
//  Copyright © 2019 Kyle Raftogianis. All rights reserved.
//

#import "UnicodeInputController.h"

extern IMKCandidates* candidatesWindow;

// See IMKInputController.h for documentation of the IMKServerInput protocol.
@implementation UnicodeInputController {
  // Buffer containing text that the user has input so far in the current
  // composition session. We ensure that the client's marked text always
  // matches the contents.
  NSMutableString* _compositionBuffer;
  // Array of NSStrings containing candidate replacements.
  NSArray* _candidateReplacements;
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

// Gets the current candidate replacements buffer, allocating if necessary.
- (NSArray*)candidateReplacements {
  if (_candidateReplacements == nil) {
    return @[];
  }
  return _candidateReplacements;
}

// Update the cached candidate replacements and candidates window to match the
// contents of the buffer.
- (void)updateCandidates {
  NSMutableString* buffer = [self compositionBuffer];
  // TODO: make this a real map.
  if ([buffer isEqualToString:@"\\r"]) {
    _candidateReplacements = @[
      @"→", @"⇒", @"⇛", @"⇉", @"⇄", @"↦", @"⇨", @"↠", @"⇀", @"⇁",
      @"⇢", @"⇻", @"↝", @"⇾", @"⟶", @"⟹", @"↛", @"⇏", @"⇸", @"⇶",
    ];
  } else {
    _candidateReplacements = @[];
  }

  if ([_candidateReplacements count] > 0) {
    [candidatesWindow updateCandidates];
    [candidatesWindow show:kIMKLocateCandidatesBelowHint];
  } else {
    [candidatesWindow hide];
  }
}

// Update the client's state match the contents of the buffer. This must be
// called whenever the buffer changes.
- (void)updateState:(id)sender {
  NSMutableString* buffer = [self compositionBuffer];
  [self updateCandidates];
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

// Inserts the contents of the buffer without making a replacement, returning to
// an inactive state.
- (void)deactivate:(id)sender {
  NSMutableString* buffer = [self compositionBuffer];
  [sender insertText:buffer
      replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
  [buffer setString:@""];
  [self updateCandidates];
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
    [[self compositionBuffer] appendString:string];
    [self updateState:sender];
    return YES;
  }
  return NO;
}

- (BOOL)didCommandBySelector:(SEL)aSelector client:(id)sender {
  NSLog(@"didCommandBySelector:%@", NSStringFromSelector(aSelector));
  if ([self isActive]) {
    if (aSelector == @selector(insertNewline:)) {
      [self deactivate:sender];
      return YES;
      // If the candidates window is open, pass arrow keys through.
    } else if ([candidatesWindow isVisible] && aSelector == @selector
                                                   (moveLeft:)) {
      [candidatesWindow moveLeft:sender];
      return YES;
    } else if ([candidatesWindow isVisible] && aSelector == @selector
                                                   (moveRight:)) {
      [candidatesWindow moveRight:sender];
      return YES;
    } else if ([candidatesWindow isVisible] && aSelector == @selector
                                                   (moveUp:)) {
      [candidatesWindow moveUp:sender];
      return YES;
    } else if ([candidatesWindow isVisible] && aSelector == @selector
                                                   (moveDown:)) {
      [candidatesWindow moveDown:sender];
      return YES;
    }
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

// Called by the system to get a list of candidates to display.
- (NSArray*)candidates:(id)sender {
  NSLog(@"candidates:");
  return [self candidateReplacements];
}

@end
