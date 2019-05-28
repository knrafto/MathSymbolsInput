//
//  main.m
//  UnicodeInput
//
//  Created by Kyle Raftogianis on 5/28/19.
//  Copyright © 2019 Kyle Raftogianis. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>

const NSString *kConnectionName = @"UnicodeInputConnection";
IMKServer *server;

int main(int argc, const char *argv[]) {
  @autoreleasepool {
    server = [[IMKServer alloc]
            initWithName:(NSString *)kConnectionName
        bundleIdentifier:[[NSBundle mainBundle] bundleIdentifier]];

    [[NSApplication sharedApplication] run];
  }
  return 0;
}
