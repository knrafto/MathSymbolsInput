import Cocoa
import InputMethodKit

// Unique connection name for this input method.
let kConnectionName = "MathSymbolsInput_1_Connection"
// .txt file containing built-in commands.
let kBuiltinCommandsResourceName = "commands"
// Preferences app name.
let kPreferencesAppBundleIdentifier = "com.mathsymbolsinput.MathSymbolsPreferences"
// UserDefaults key for built-in commands.
let kBuiltinCommandsKey = "BuiltinCommands"
// UserDefaults key for custom commands.
let kCustomCommandsKey = "CustomCommands"
// UserDefaults key for the preferences tab.
let kPreferencesTabKey = "PreferencesTab"

// Load the replacements.
loadBuiltinCommands()

// Set up the menu in the menu bar.
let mainMenu = NSMenu()
mainMenu.addItem(withTitle: "Edit Custom Commands...", action: #selector(InputController.showCustomCommands(_:)), keyEquivalent: "")
mainMenu.addItem(withTitle: "View Built-in Commands...", action: #selector(InputController.showBuiltinCommands(_:)), keyEquivalent: "")
mainMenu.addItem(withTitle: "About", action: #selector(InputController.showAbout(_:)), keyEquivalent: "")

// Server that accepts connections from client applications. It will create an
// InputController instance to handle each client connection.
let server = IMKServer.init(name: kConnectionName, bundleIdentifier: Bundle.main.bundleIdentifier!)

// Run the app.
NSApplication.shared.run()
