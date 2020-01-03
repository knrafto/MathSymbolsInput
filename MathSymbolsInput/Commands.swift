import Foundation
import Cocoa

// Map from escape sequences to replacements.
var defaultCommands : [String : String] = [:]

func loadDefaultCommands() {
  let path = Bundle.main.path(forResource: kDefaultCommandsResourceName, ofType: "txt")
  if path == nil {
    NSLog("No file %@.txt in %@", kDefaultCommandsResourceName, Bundle.main.resourcePath!)
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
  for line in contents.split(whereSeparator: { $0 == "\n" || $0 == "\r\n" }) {
    lineNumber += 1
    // Blank or comment line
    if line.isEmpty || line.starts(with: "#") {
      continue
    }

    let components = line.split(separator: " ", maxSplits: 1)
    if components.count != 2 {
      NSLog("Syntax error on line %d: expected exactly two words separated by whitespace",
            lineNumber)
      continue
    }
    // TODO: validate command and replacement.
    let command = String(components[0])
    let replacement = String(components[1])

    if !command.starts(with: "\\") {
      NSLog("Syntax error on line %d: command must start with a backslash",
            lineNumber)
      continue
    }

    if defaultCommands[command] != nil {
      NSLog("Error on line %d: command '%@' already defined",
            lineNumber, command)
      continue
    }

    defaultCommands[command] = replacement
  }

  // Save commands to UserDefaults so the preferences app can read them easily.
  UserDefaults.standard.set(defaultCommands, forKey: kDefaultCommandsKey)

  NSLog("Loaded %d default commands", defaultCommands.count)
}

// Look up a command's replacement, first in the user's preferences and then
// in the default commands.
func findReplacement(forCommand command: String) -> String? {
  let customCommands = UserDefaults.standard.dictionary(forKey: kCustomCommandsKey)
  var replacement = customCommands?[command] as? String
  if replacement == nil {
    replacement = defaultCommands[command]
  }
  return replacement
}
