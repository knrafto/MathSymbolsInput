//
//  Commands.swift
//  UnicodeInput
//
//  Created by Kyle Raftogianis on 6/8/19.
//  Copyright © 2019 Kyle Raftogianis. All rights reserved.
//

import Foundation
import Cocoa

// Map from escape sequences to replacements.
var builtinCommands : [String : String] = [:]

func loadBuiltinCommands() {
  let path = Bundle.main.path(forResource: kBuiltinCommandsResourceName, ofType: "txt")
  if path == nil {
    NSLog("No file %@.txt in %@", kBuiltinCommandsResourceName, Bundle.main.resourcePath!)
    return
  }
  NSLog("Loading commands from %@", path!)

  var contents = ""
  do {
    contents = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
  } catch {
    NSLog("Could not read %@: %@", path!, error.localizedDescription)
    return
  }

  var lineNumber = 0
  for line in contents.components(separatedBy: "\n") {
    lineNumber += 1
    // Blank or comment line
    if line.isEmpty || line.starts(with: "#") {
      continue
    }

    let components = line.components(separatedBy: " ")
    if components.count != 2 {
      NSLog("Syntax error on line %d: expected exactly two words separated by whitespace",
            lineNumber)
      continue
    }
    let command = components[0]
    let replacement = components[1]

    if !command.starts(with: "\\") {
      NSLog("Syntax error on line %d: command must start with a backslash",
            lineNumber)
      continue
    }

    if builtinCommands[command] != nil {
      NSLog("Error on line %d: command '%@' already defined",
            lineNumber, command)
      continue
    }

    builtinCommands[command] = replacement
  }

  NSLog("Loaded %d built-in commands", builtinCommands.count)
}

// Look up a command's replacement, first in the user's preferences and then
// in the built-in commands.
func findReplacement(forCommand command: String) -> String? {
  let customCommands = UserDefaults.standard.dictionary(forKey: kCustomCommandsKey)
  var replacement = customCommands?[command] as? String
  if replacement == nil {
    replacement = builtinCommands[command]
  }
  return replacement
}
