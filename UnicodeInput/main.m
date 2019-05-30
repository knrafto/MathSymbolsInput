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
  NSLog(@"Loading replacements...");

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
  int num_replacements = 0;
  char str[BUFFER_SIZE];
  while (true) {
    line++;
    if (fgets(str, BUFFER_SIZE, f) == NULL) {
      if (ferror(f)) {
        NSLog(@"Error reading file: %s", strerror(errno));
        return nil;
      }
      // EOF
      break;
    }

    size_t len = strlen(str);

    // Blank or comment line
    if (str[0] == '#' || str[0] == '\n')
      continue;

    if (str[0] != '\\') {
      NSLog(@"Syntax error on line %d: escape sequence must start with a "
            @"backslash",
            line);
      return nil;
    }

    char* space = strchr(str, ' ');
    if (space == NULL) {
      NSLog(@"Syntax error on line %d: line does not contain a space", line);
      return nil;
    }

    // Make C strings out of the escape sequence and replacement
    *space = '\0';
    str[len - 1] = '\0';

    NSString* escape = [NSString stringWithUTF8String:str];
    NSString* replacement = [NSString stringWithUTF8String:(space + 1)];

    NSMutableArray* replacements_for_escape = mutableReplacementsMap[escape];
    if (replacements_for_escape == nil) {
      replacements_for_escape = [[NSMutableArray alloc] init];
      [mutableReplacementsMap setObject:replacements_for_escape forKey:escape];
    }
    [replacements_for_escape addObject:replacement];

    num_replacements++;
  }

  NSLog(@"Loaded %d replacements", num_replacements);
  return mutableReplacementsMap;
}

int main(int argc, const char* argv[]) {
  replacementsMap = loadReplacementsMap();
  if (replacementsMap == nil) {
    NSLog(@"Failed to load replacements!");
    // Fall back to empty replacements instead of exiting. If the input method
    // crashes, the system will refuse to restart it.
    replacementsMap = @{};
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
