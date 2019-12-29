//
//  ViewController.swift
//  MathSymbolsPreferences
//
//  Created by Kyle Raftogianis on 12/29/19.
//  Copyright © 2019 Kyle Raftogianis. All rights reserved.
//

import Cocoa

class CustomCommandsController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
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
    if row == -1 {
      return
    }
    let column = sender.superview!.identifier!.rawValue
    contents[row][column] = sender.stringValue
    savePreferences()
  }

  // Called when a +/- button is clicked.
  @IBAction func buttonClicked(_ sender: NSSegmentedControl) {
    if sender.selectedSegment == 0 {
      addItem()
    } else if sender.selectedSegment == 1 {
      removeItem()
    }
  }

  func addItem() {
    contents.append([
      "command": "\\",
      "replacement": "",
    ])
    tableView.reloadData()

    // Automatically select and edit the new item.
    let newRow = contents.count - 1
    tableView.selectRowIndexes(IndexSet(integer: newRow), byExtendingSelection: false)
    let view = tableView.view(atColumn: 0, row: newRow, makeIfNecessary: true) as! NSTableCellView
    view.textField?.becomeFirstResponder()
    let range = view.textField?.currentEditor()?.selectedRange
    view.textField?.currentEditor()?.selectedRange = NSMakeRange(range?.length ?? 0, 0)

    savePreferences()
  }

  func removeItem() {
    if tableView.selectedRow == -1 {
      return
    }
    contents.remove(at: tableView.selectedRow)

    tableView.reloadData()
    savePreferences()
  }
}

