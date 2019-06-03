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
const size_t MAX_LINE_LENGTH = 4096;

// Server that accepts connections from client applications. It will create a
// UnicodeInputController instance to handle each client connection.
IMKServer* server = nil;

// Map from NSString* escape sequences NSString* replacements.
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

  int line_number = 0;
  char line[MAX_LINE_LENGTH];
  while (true) {
    line_number++;
    if (fgets(line, MAX_LINE_LENGTH, f) == NULL) {
      if (ferror(f)) {
        NSLog(@"Error reading file: %s", strerror(errno));
        return nil;
      } else {
        // EOF
        break;
      }
    }

    // Trim newline
    size_t line_length = strlen(line);
    if (line[line_length - 1] == '\n') {
      line[line_length - 1] = '\0';
    } else if (!feof(f)) {
      NSLog(@"Line %d too long", line_number);
      return nil;
    }

    // Blank or comment line
    if (line[0] == '\0' || line[0] == '#') {
      continue;
    }

    if (line[0] != '\\') {
      NSLog(@"Syntax error on line %d: escape sequence must start with a "
            @"backslash",
            line_number);
      return nil;
    }

    char* space = strchr(line, ' ');
    if (space == NULL) {
      NSLog(@"Syntax error on line %d: no replacement for escape sequence",
            line_number);
      return nil;
    }

    *space = '\0';
    NSString* escape = [NSString stringWithUTF8String:line];
    NSString* replacement = [NSString stringWithUTF8String:(space + 1)];

    if (mutableReplacementsMap[escape] != nil) {
      NSLog(@"Error on line %d: escape sequence '%@' already defined",
            line_number, escape);
      return nil;
    }
    [mutableReplacementsMap setObject:replacement forKey:escape];
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
  // Run the event loop.
  [[NSApplication sharedApplication] run];
  return 0;
}
