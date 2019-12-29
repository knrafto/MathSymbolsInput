//
//  ViewController.swift
//  UnicodeInputPreferences
//
//  Created by Kyle Raftogianis on 12/29/19.
//  Copyright © 2019 Kyle Raftogianis. All rights reserved.
//

import Cocoa

let suiteName = "com.knrafto.inputmethod.UnicodeInput"
let customCommandsKey = "CustomCommands"

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
  @IBOutlet weak var tableView: NSTableView!
  var preferences: UserDefaults?
  // Table contents, as a list of (column id -> value) dictionaries.
  var contents: [[String: String]] = []

  override func viewDidLoad() {
    super.viewDidLoad()

    preferences = UserDefaults(suiteName: suiteName)
    let customCommands = preferences?.dictionary(forKey: customCommandsKey) ?? [:]
    for command in Array(customCommands.keys).sorted() {
      guard let replacement = customCommands[command] as? String else {
        continue
      }
      contents.append([
        "command": command,
        "replacement": replacement,
      ])
    }
  }

  // Saves the current state to preferences.
  func savePreferences() {
    var customCommands: [String : String] = [:]
    for rowDict in contents {
      customCommands[rowDict["command"]!] = rowDict["replacement"]!
    }
    preferences?.set(customCommands, forKey: customCommandsKey)
  }

  // For NSTableViewDataSource.
  func numberOfRows(in tableView: NSTableView) -> Int {
    return contents.count
  }

  // For NSTableViewDelegate.
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    let view = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
    view.textField?.stringValue = contents[row][tableColumn!.identifier.rawValue]!
    return view
  }

  // Called when a table cell is edited.
  @IBAction func doneEditing(_ sender: NSTextField) {
    let row = tableView.row(for: sender.superview!)
    let column = sender.superview!.identifier!.rawValue
    contents[row][column] = sender.stringValue
    savePreferences()
  }
}

