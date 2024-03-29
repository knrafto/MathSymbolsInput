import Foundation
import Cocoa

class DefaultCommandsController : NSViewController, NSTableViewDataSource, NSTableViewDelegate {
  @IBOutlet weak var tableView: NSTableView!
  // Table contents, as a list of (column id -> value) dictionaries.
  var contents: [[String: String]] = []
  var filteredContents: [[String: String]] = []

  override func viewDidLoad() {
    super.viewDidLoad()

    let preferences = UserDefaults(suiteName: kSuiteName)
    let defaultCommands = preferences?.dictionary(forKey: kDefaultCommandsKey) ?? [:]
    for command in Array(defaultCommands.keys).sorted() {
      guard let replacement = defaultCommands[command] as? String else {
        continue
      }
      contents.append([
        "command": command,
        "replacement": replacement,
      ])
    }
    filteredContents = contents
    tableView.reloadData()

    // Work around macOS bug where the header obscures the first row
    if (tableView.numberOfRows > 0) {
      tableView.scrollRowToVisible(0)
    }
  }

  // For NSTableViewDataSource.
  func numberOfRows(in tableView: NSTableView) -> Int {
    return filteredContents.count
  }

  // For NSTableViewDelegate.
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    let view = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
    view.textField?.stringValue = filteredContents[row][tableColumn!.identifier.rawValue]!
    return view
  }

  // Called when the user types in a search.
  @IBAction func search(_ sender: NSSearchField) {
    let searchText = sender.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
    if searchText.isEmpty {
      filteredContents = contents
    } else {
      filteredContents = contents.filter {
        return $0["command"]!.contains(searchText) || $0["replacement"]!.contains(searchText)
      }
    }
    tableView.reloadData()
  }
}
