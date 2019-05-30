//
//  UnicodeInputController.m
//  UnicodeInput
//
//  Created by Kyle Raftogianis on 5/28/19.
//  Copyright © 2019 Kyle Raftogianis. All rights reserved.
//

#import "UnicodeInputController.h"

extern IMKCandidates* candidatesWindow;
extern NSDictionary* replacementsMap;

// Like NSLog, but only logs in debug mode.
void DLog(NSString* format, ...) {
#ifdef DEBUG
  va_list args;
  va_start(args, format);
  NSLogv(format, args);
  va_end(args);
#endif
}

// See IMKInputController.h for documentation of the IMKServerInput protocol.
@implementation UnicodeInputController {
  // Buffer containing text that the user has input so far in the current
  // composition session. We ensure that the client's marked text always
  // matches the contents.
  NSMutableString* _compositionBuffer;
  // Array of NSStrings containing candidate replacements.
  NSArray* _candidateReplacements;
  // The currently-selected candidate, if any.
  NSString* _currentSelection;
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

// Update the client's state match the contents of the buffer. This must be
// called whenever the buffer changes.
- (void)bufferChanged:(id)sender {
  NSMutableString* buffer = [self compositionBuffer];

  _candidateReplacements = replacementsMap[buffer];
  if (_candidateReplacements == nil) {
    _candidateReplacements = @[];
  }

  if ([_candidateReplacements count] > 0) {
    [candidatesWindow updateCandidates];
    [candidatesWindow show:kIMKLocateCandidatesBelowHint];
    _currentSelection = _candidateReplacements[0];
  } else {
    [candidatesWindow hide];
    _currentSelection = nil;
  }

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

// Accepts the currently-chosen replacement.
- (void)accept:(id)sender {
  NSMutableString* buffer = [self compositionBuffer];
  NSString* acceptedString =
      _currentSelection != nil ? _currentSelection : buffer;
  [sender insertText:acceptedString
      replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
  [buffer setString:@""];
  [self bufferChanged:sender];
}

// Inserts the contents of the buffer without making a replacement, returning to
// an inactive state.
- (void)deactivate:(id)sender {
  NSMutableString* buffer = [self compositionBuffer];
  [sender insertText:buffer
      replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
  [buffer setString:@""];
  [self bufferChanged:sender];
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
  DLog(@"inputText:%@", string);
  if ([string isEqualToString:@"\\"]) {
    NSMutableString* buffer = [self compositionBuffer];
    [self accept:sender];
    [buffer appendString:string];
    [self bufferChanged:sender];
    return YES;
  } else if ([self isActive] && [string isEqualToString:@" "]) {
    [self accept:sender];
    return NO;
  } else if ([self isActive]) {
    [[self compositionBuffer] appendString:string];
    [self bufferChanged:sender];
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
  DLog(@"didCommandBySelector:%@", NSStringFromSelector(aSelector));
  if ([self isActive]) {
    if (aSelector == @selector(insertNewline:) || aSelector == @selector
                                                      (insertTab:)) {
      [self accept:sender];
      return YES;
    } else if (aSelector == @selector(deleteBackward:)) {
      NSMutableString* buffer = [self compositionBuffer];
      [buffer deleteCharactersInRange:NSMakeRange([buffer length] - 1, 1)];
      [self bufferChanged:sender];
      return YES;
    } else if (aSelector == @selector(cancelOperation:)) {
      [self deactivate:sender];
      return YES;
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
  DLog(@"commitComposition:");
  [self deactivate:sender];
}

// Called by the system to get a list of candidates to display.
- (NSArray*)candidates:(id)sender {
  DLog(@"candidates:");
  return [self candidateReplacements];
}

// Called by the system when the user selects a candidate.
- (void)candidateSelectionChanged:(NSAttributedString*)candidateString {
  DLog(@"candidateSelectionChanged:%@", candidateString);
  _currentSelection = [candidateString string];
}

// Called by the system when the user accepts a candidate.
- (void)candidateSelected:(NSAttributedString*)candidateString {
  DLog(@"candidateSelected:%@", candidateString);
  _currentSelection = [candidateString string];
  [self accept:[self client]];
}

@end
