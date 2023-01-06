#include "Commands.h"

#import <Foundation/Foundation.h>

// .txt file containing default commands.
static NSString *kDefaultCommandsResourceName = @"commands";
// NSUserDefaults key for default commands.
static NSString *kDefaultCommandsKey = @"DefaultCommands";
// NSUserDefaults key for custom commands.
static NSString *kCustomCommandsKey = @"CustomCommands";

// Map from NSString* commands NSString* replacements.
static NSMutableDictionary *defaultCommands = nil;

void loadDefaultCommands(void) {
  defaultCommands = [[NSMutableDictionary alloc] init];
  NSBundle *bundle = [NSBundle mainBundle];
  NSString *path = [bundle pathForResource:kDefaultCommandsResourceName ofType:@"txt"];
  if (path == nil) {
    NSLog(@"No file %@.txt in %@", kDefaultCommandsResourceName, [bundle resourcePath]);
    return;
  }
  NSLog(@"Loading commands from %@", path);

  NSError *error = nil;
  NSString *contents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
  if (contents == nil) {
    NSLog(@"Could not read %@: %@", path, [error localizedDescription]);
    return;
  }

  int errors = 0;
  int lineNumber = 0;
  // TODO: handle \r\n line endings.
  for (NSString *line in [contents componentsSeparatedByString:@"\n"]) {
    lineNumber++;
    // Blank or comment line.
    if ([line length] == 0 || [line hasPrefix:@"#"]) {
      continue;
    }

    NSUInteger i = [line rangeOfString:@" "].location;
    if (i == NSNotFound) {
      NSLog(@"Syntax error on line %d: expected command and replacement separated by a space", lineNumber);
      errors++;
      continue;
    }

    // TODO: validate command and replacement.
    NSString *command = [line substringToIndex:i];
    NSString *replacement = [line substringFromIndex:(i + 1)];

    if (![line hasPrefix:@"\\"]) {
      NSLog(@"Syntax error on line %d: command must start with a backslash", lineNumber);
      errors++;
      continue;
    }

    if (defaultCommands[command] != nil) {
      NSLog(@"Error on line %d: command '%@' already defined", lineNumber, command);
      errors++;
      continue;
    }

    [defaultCommands setObject:replacement forKey:command];
  }

  // Save commands to UserDefaults so the preferences app can read them easily.
  [[NSUserDefaults standardUserDefaults] setObject:defaultCommands forKey:kDefaultCommandsKey];

  NSLog(@"Loaded %lu default commands with %d errors", (unsigned long)[defaultCommands count], errors);
}

NSString *findReplacement(NSString *command) {
  NSDictionary *customCommands = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kCustomCommandsKey];
  if (customCommands != nil) {
    id replacement = customCommands[command];
    if (replacement != nil && [replacement isKindOfClass:[NSString class]]) {
      return replacement;
    }
  }

  return defaultCommands[command];
}
