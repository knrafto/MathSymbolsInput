//
//  main.m
//  UnicodeInput
//
//  Created by Kyle Raftogianis on 5/28/19.
//  Copyright © 2019 Kyle Raftogianis. All rights reserved.
//

#include <stdio.h>
#include <string.h>

#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>

// Unique connection name for this input method.
const NSString* kConnectionName = @"UnicodeInputConnection";

// Also controls maximum line length.
const size_t BUFFER_SIZE = 4096;

// Server that accepts connections from client applications. It will create a
// UnicodeInputController instance to handle each client connection.
IMKServer* server = nil;
// Window that displays candidate replacements.
IMKCandidates* candidatesWindow = nil;

// Map from escape sequences (an NSString*) to NSArray* of NSString*
// replacements.
NSDictionary* replacementsMap = nil;

// Load the replacements map. Returns nil on error.
NSDictionary* loadReplacementsMap(void) {
  NSMutableDictionary* mutableReplacementsMap =
      [[NSMutableDictionary alloc] init];
  NSBundle* bundle = [NSBundle mainBundle];
  NSString* replacementsPath = [bundle pathForResource:@"replacements"
                                                ofType:@"txt"];
  if (replacementsPath == nil) {
    NSLog(@"No file replacements.txt in %@", [bundle resourcePath]);
    return nil;
  }

  FILE* f = fopen([replacementsPath UTF8String], "r");
  if (f == NULL) {
    NSLog(@"Could not open %@: %s", replacementsPath, strerror(errno));
    return nil;
  }

  int line = 0;
  char buffer[BUFFER_SIZE];
  while (true) {
    line++;
    if (fgets(buffer, BUFFER_SIZE, f) == NULL) {
      if (ferror(f)) {
        NSLog(@"Error reading file: %s", strerror(errno));
        return nil;
      } else {
        // EOF
        break;
      }
    }

    char* escape_token = strtok(buffer, " \t\r\n");
    // Blank or comment line
    if (escape_token == NULL || escape_token[0] == '#') {
      continue;
    }

    if (escape_token[0] != '\\') {
      NSLog(@"Syntax error on line %d: escape sequence must start with a "
            @"backslash",
            line);
      return nil;
    }

    NSMutableArray* replacements = [[NSMutableArray alloc] init];
    char* replacement_token;
    while ((replacement_token = strtok(NULL, " \t\r\n")) != NULL) {
      [replacements
          addObject:[NSString stringWithUTF8String:replacement_token]];
    }

    if ([replacements count] == 0) {
      NSLog(@"Syntax error on line %d: no replacements for escape sequence",
            line);
      return nil;
    }

    NSString* escape = [NSString stringWithUTF8String:escape_token];
    if (mutableReplacementsMap[escape] != nil) {
      NSLog(@"Error on line %d: escape sequence '%@' already has replacements",
            line, escape);
      return nil;
    }
    [mutableReplacementsMap setObject:replacements forKey:escape];
  }

  return mutableReplacementsMap;
}

int main(int argc, const char* argv[]) {
  NSLog(@"Loading replacements...");
  replacementsMap = loadReplacementsMap();
  if (replacementsMap == nil) {
    NSLog(@"Failed to load replacements!");
    // Fall back to empty replacements instead of exiting. If the input method
    // crashes, the system will refuse to restart it.
    replacementsMap = @{};
  } else {
    NSLog(@"Loaded %lu replacements", (unsigned long)[replacementsMap count]);
  }

  // Create the server.
  server =
      [[IMKServer alloc] initWithName:(NSString*)kConnectionName
                     bundleIdentifier:[[NSBundle mainBundle] bundleIdentifier]];
  // Create the candidates window.
  candidatesWindow =
      [[IMKCandidates alloc] initWithServer:server
                                  panelType:kIMKScrollingGridCandidatePanel];
  // Run the event loop.
  [[NSApplication sharedApplication] run];
  return 0;
}
