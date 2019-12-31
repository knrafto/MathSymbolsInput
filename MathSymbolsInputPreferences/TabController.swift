import Foundation
import Cocoa

class TabController : NSTabViewController {
  override func viewDidAppear() {
    switchSelectedTab()
  }

  // Switches tabs depending on what menu item the user clicked to get here
  // (communicated through UserDefaults).
  func switchSelectedTab() {
    let preferences = UserDefaults(suiteName: kSuiteName)
    guard let targetTabId = preferences?.string(forKey: kPreferencesTabKey) else {
      return
    }
    for (i, tabViewItem) in tabViewItems.enumerated() {
      guard let tabId = tabViewItem.identifier as? String else {
        continue
      }
      if tabId == targetTabId {
        selectedTabViewItemIndex = i
        break
      }
    }
  }
}
