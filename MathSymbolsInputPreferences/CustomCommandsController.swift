import Cocoa

class CustomCommandsController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
  @IBOutlet weak var tableView: NSTableView!
  var preferences: UserDefaults?
  // Table contents, as a list of (column id -> value) dictionaries.
  var contents: [[String: String]] = []

  override func viewDidLoad() {
    super.viewDidLoad()

    preferences = UserDefaults(suiteName: kSuiteName)
    let customCommands = preferences?.dictionary(forKey: kCustomCommandsKey) ?? [:]
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
    preferences?.set(customCommands, forKey: kCustomCommandsKey)
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

  func addItem() {
    // End any current editing.
    tableView.window?.makeFirstResponder(nil)

    // Add a new row.
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
    // Remove indices in reverse order so items don't move around while we remove them.
    for i in tableView.selectedRowIndexes.sorted(by: >) {
      contents.remove(at: i)
    }

    tableView.reloadData()
    savePreferences()
  }

  // Called when a table cell is edited.
  @IBAction func doneEditing(_ sender: NSTextField) {
    let row = tableView.row(for: sender.superview!)
    if row == -1 {
      return
    }
    let column = sender.superview!.identifier!.rawValue

    // Trim whitespace
    let text = sender.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
    sender.stringValue = text
    contents[row][column] = text
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

  // Called when the table is double-clicked.
  @IBAction func doubleClicked(_ sender: Any) {
    if tableView.clickedRow == -1 && tableView.clickedColumn == -1 {
      // The user clicked outside a row.
      addItem()
    } else if tableView.clickedRow != -1 && tableView.clickedColumn != -1 {
      // The user double-clicked a row. Edit the cell.
      let view = tableView.view(atColumn: tableView.clickedColumn, row: tableView.clickedRow, makeIfNecessary: true) as! NSTableCellView
      view.textField?.becomeFirstResponder()
    }
  }
}

