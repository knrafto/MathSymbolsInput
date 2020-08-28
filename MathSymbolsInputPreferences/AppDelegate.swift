import Cocoa

// Bundle identifer of the main input method.
let kSuiteName = "com.mathsymbolsinput.inputmethod.MathSymbolsInput"
// UserDefaults key for default commands.
let kDefaultCommandsKey = "DefaultCommands"
// UserDefaults key for custom commands.
let kCustomCommandsKey = "CustomCommands"
// UserDefaults key for the preferences tab.
let kPreferencesTabKey = "PreferencesTab"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(_ notification: Notification) {
    NSApp.activate(ignoringOtherApps: true)
  }

  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    // The user clicked a menu item from the input method menu. Update the current tab
    // to reflect their choice
    let tabController = NSApp.mainWindow?.contentViewController as? TabController
    tabController?.switchSelectedTab()
    return true
  }

  func applicationWillResignActive(_ notification: Notification) {
    // Ensure any currently-edited command gets saved
    NSApp.mainWindow?.makeFirstResponder(NSApp.mainWindow?.initialFirstResponder);
    NSApp.terminate(nil);
  }

  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }
}

