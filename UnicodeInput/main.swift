//
//  main.swift
//  UnicodeInput
//
//  Created by Kyle Raftogianis on 6/9/19.
//  Copyright © 2019 Kyle Raftogianis. All rights reserved.
//

import Cocoa
import InputMethodKit

// Unique connection name for this input method.
let kConnectionName = "UnicodeInput_1_Connection";

// Load the replacements.
loadBuiltinReplacements()
loadCustomReplacements()

// Set up the menu in the menu bar.
let mainMenu = NSMenu()
mainMenu.addItem(withTitle: "Preferences…", action: #selector(UnicodeInputController.showPreferences(_:)), keyEquivalent: "")

// Load UI.
let customCommandsController = NSStoryboard(name: "CustomCommands", bundle: nil).instantiateInitialController() as! NSWindowController

// Server that accepts connections from client applications. It will create a
// UnicodeInputController instance to handle each client connection.
let server = IMKServer.init(name: kConnectionName, bundleIdentifier: Bundle.main.bundleIdentifier!)

// Run the app.
NSApplication.shared.run()
