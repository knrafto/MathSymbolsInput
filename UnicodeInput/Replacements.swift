//
//  Replacements.swift
//  UnicodeInput
//
//  Created by Kyle Raftogianis on 6/8/19.
//  Copyright © 2019 Kyle Raftogianis. All rights reserved.
//

import Foundation

// Map from escape sequences to replacements.
var globalReplacementsMap = Dictionary<String, String>()

class Replacements : NSObject {
  @objc static func loadReplacementsMap() {
    var replacementsMap = Dictionary<String, String>()

    let path = Bundle.main.path(forResource: "replacements", ofType: "txt")
    if path == nil {
      NSLog("No file replacements.txt in %@", Bundle.main.resourcePath!)
      return
    }
    NSLog("Loading replacements from %@", path!)

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
               lineNumber);
        return
      }
      let escape = components[0]
      let replacement = components[1]

      if !escape.starts(with: "\\") {
        NSLog("Syntax error on line %d: escape sequence must start with a backslash",
           lineNumber);
        return
      }

      if replacementsMap[escape] != nil {
        NSLog("Error on line %d: escape sequence '%@' already defined",
               lineNumber, escape);
        return
      }

      replacementsMap[escape] = replacement
    }

    globalReplacementsMap = replacementsMap
    NSLog("Loadied %d replacements", globalReplacementsMap.count);
  }
}