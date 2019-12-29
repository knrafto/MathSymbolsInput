//
//  BuiltinCommandsController.swift
//  MathSymbolsPreferences
//
//  Created by Kyle Raftogianis on 12/29/19.
//  Copyright © 2019 Kyle Raftogianis. All rights reserved.
//

import Foundation
import Cocoa

class BuiltinCommandsController : NSViewController, NSTableViewDataSource, NSTableViewDelegate {
  // Table contents, as a list of (column id -> value) dictionaries.
  var contents: [[String: String]] = []

  override func viewDidLoad() {
    super.viewDidLoad()

    let preferences = UserDefaults(suiteName: kSuiteName)
    let builtinCommands = preferences?.dictionary(forKey: kBuiltinCommandsKey) ?? [:]
    for command in Array(builtinCommands.keys).sorted() {
      guard let replacement = builtinCommands[command] as? String else {
        continue
      }
      contents.append([
        "command": command,
        "replacement": replacement,
      ])
    }
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
}
