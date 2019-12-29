//
//  AppDelegate.swift
//  UnicodeInputPreferences
//
//  Created by Kyle Raftogianis on 12/29/19.
//  Copyright © 2019 Kyle Raftogianis. All rights reserved.
//

import Cocoa

let suiteName = "com.mathsymbolsinput.inputmethod.MathSymbolsInput"
let customCommandsKey = "CustomCommands"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  func applicationShouldTerminateAfterLastWindowClosed(_ theApplication: NSApplication) -> Bool {
    return true
  }
}

