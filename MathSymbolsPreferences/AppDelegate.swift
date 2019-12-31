//
//  AppDelegate.swift
//  MathSymbolsPreferences
//
//  Created by Kyle Raftogianis on 12/29/19.
//  Copyright © 2019 Kyle Raftogianis. All rights reserved.
//

import Cocoa

// Bundle identifer of the main input method.
let kSuiteName = "com.mathsymbolsinput.inputmethod.MathSymbolsInput"
// UserDefaults key for built-in commands.
let kBuiltinCommandsKey = "BuiltinCommands"
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

  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }
}

