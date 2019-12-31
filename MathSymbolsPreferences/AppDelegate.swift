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

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(_ notification: Notification) {
    NSApp.activate(ignoringOtherApps: true)
  }

  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }
}

