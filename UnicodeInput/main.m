//
//  main.m
//  UnicodeInput
//
//  Created by Kyle Raftogianis on 5/28/19.
//  Copyright © 2019 Kyle Raftogianis. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>

// Unique connection name for this input method.
const NSString* kConnectionName = @"UnicodeInputConnection";

// Server that accepts connections from client applications. It will create a
// UnicodeInputController instance to handle each client connection.
IMKServer* server;

int main(int argc, const char* argv[]) {
  @autoreleasepool {
    // Create the server.
    server = [[IMKServer alloc]
            initWithName:(NSString*)kConnectionName
        bundleIdentifier:[[NSBundle mainBundle] bundleIdentifier]];

    // Run the event loop.
    [[NSApplication sharedApplication] run];
  }
  return 0;
}
