//
//  CustomCommandsController.swift
//  UnicodeInput
//
//  Created by Kyle Raftogianis on 12/28/19.
//  Copyright © 2019 Kyle Raftogianis. All rights reserved.
//

import Foundation
import Cocoa

class CustomCommandsController : NSViewController, NSTableViewDataSource, NSTableViewDelegate {
  @IBOutlet weak var tableView: NSTableView!

  var data: [(String, String)] = []

  // Part of NSTableViewDataSource. Returns the number of rows in the table.
  func numberOfRows(in tableView: NSTableView) -> Int {
    return data.count
  }

  // Part of NSTableViewDataSource. Returns the value of a table cell.
  func tableView(_ tableView: NSTableView,
                 objectValueFor tableColumn: NSTableColumn?,
                 row: Int) -> Any? {
    let pair = data[row]

    let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
    if tableColumn!.identifier.rawValue == "command" {
      cell.textField?.stringValue = pair.0
    } else if tableColumn!.identifier.rawValue == "replacement" {
      cell.textField?.stringValue = pair.1
    }

    return cell
  }

  // Part of NSTableViewDataSource. Returns the value of a table cell.
  func tableView(_ tableView: NSTableView,
                 setObjectValue object: Any?,
                 for tableColumn: NSTableColumn?,
                 row: Int) {
    let pair = data[row]
    guard let value = object as? String else { return }
    if tableColumn!.identifier.rawValue == "command" {
      data[row] = (value, pair.1)
    } else if tableColumn!.identifier.rawValue == "replacement" {
      data[row] = (pair.0, value)
    }

    save()
  }

  // Called when the +/- buttons are clicked.
  @IBAction func buttonClicked(_ sender: NSSegmentedControl) {
    if sender.selectedSegment == 0 {
      addRow()
    } else if sender.selectedSegment == 1 {
      removeRow()
    }
  }

  func addRow() {
    data.append(("", ""))
    tableView.reloadData()
    save()
  }

  func removeRow() {
    if tableView.selectedRow != -1 {
      data.remove(at: tableView.selectedRow)
    }
    tableView.reloadData()
    save()
  }

  // Saves the current data in UserDefaults and updates the input method.
  func save() {
    // TODO: actually save
    loadCustomReplacements()
  }
}
