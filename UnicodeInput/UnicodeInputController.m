//
//  UnicodeInputController.m
//  UnicodeInput
//
//  Created by Kyle Raftogianis on 5/28/19.
//  Copyright © 2019 Kyle Raftogianis. All rights reserved.
//

#import "UnicodeInputController.h"

@implementation UnicodeInputController

// Handles a key down event that does not map to an "action method" (i.e. most
// typed characters). Returns YES if we handled the event, and NO if it should
// be passed to the client instead.
- (BOOL)inputText:(NSString*)string client:(id)sender {
  NSLog(@"inputText:%@", string);
  return NO;
}

// Handles an "action method" (namely deleteBackward: and insertNewline:).
// Returns YES if we handled the event, and NO if it should be passed to the
// client instead.
- (BOOL)didCommandBySelector:(SEL)aSelector client:(id)sender {
  NSLog(@"didCommandBySelector:%@", NSStringFromSelector(aSelector));
  return NO;
}

// Called by the system when the client wants to end composition immediately
// (e.g. the user selected a new input method).
- (void)commitComposition:(id)sender {
  NSLog(@"commitComposition:");
}

@end
