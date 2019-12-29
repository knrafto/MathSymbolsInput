//
//  UnicodeInputController.swift
//  UnicodeInput
//
//  Created by Kyle Raftogianis on 6/8/19.
//  Copyright © 2019 Kyle Raftogianis. All rights reserved.
//

import Foundation
import InputMethodKit

// See IMKInputController.h for documentation of the IMKServerInput protocol.
class UnicodeInputController : IMKInputController {
  // Buffer containing text that the user has input so far in the current
  // composition session. We ensure that the client's marked text always
  // matches the contents.
  private var compositionBuffer: String = ""

  // Returns whether there is an active composition session.
  func isActive() -> Bool {
    return !compositionBuffer.isEmpty
  }

  // Update the client's state match the contents of the buffer. This must be
  // called whenever the buffer changes.
  func bufferChanged() {
    // Seems like using an NSAttributedString for setMarkedText is necessary to
    // get the cursor to appear at the end of the marked text instead of selecting
    // the whole range.
    let range = NSMakeRange(0, compositionBuffer.count)
    let attributes = mark(forStyle: kTSMHiliteSelectedRawText, at: range) as! [NSAttributedString.Key : Any]
    let attrString = NSAttributedString(string: compositionBuffer, attributes: attributes)
    client().setMarkedText(attrString, selectionRange: range, replacementRange: NSMakeRange(NSNotFound, NSNotFound))
  }

  // Accepts the currently-chosen replacement.
  func accept() {
    let replacement = builtinReplacements[compositionBuffer]
    let acceptedString = replacement != nil ? replacement : compositionBuffer
    client().insertText(acceptedString, replacementRange: NSMakeRange(NSNotFound, NSNotFound))
    compositionBuffer = ""
    bufferChanged()
  }

  // Inserts the contents of the buffer without making a replacement, returning to
  // an inactive state.
  func deactivate() {
    client().insertText(compositionBuffer, replacementRange: NSMakeRange(NSNotFound, NSNotFound))
    compositionBuffer = ""
    bufferChanged()
  }

  // On keydown events, the system will either call inputText: (for most typed
  // characters) or didCommandBySelector: (for special actions e.g. pressing
  // backspace). These methods return YES if we handled the event, and NO if the
  // event should be passed to the client instead. We ensure that the composition
  // is inactive before passing any events on to the client to prevent surprising
  // behavior.

  // Handles the following events:
  //   * backslash: accept current selection, start new composition
  //   * space (if active): accept current selection, insert space
  //   * all other characters (if active): append to buffer
  override func inputText(_ string: String, client sender: Any!) -> Bool {
    if string == "\\" {
      accept()
      compositionBuffer += string
      bufferChanged()
      return true
    } else if isActive() && string == " " {
      accept()
      return false
    } else if isActive() {
      compositionBuffer += string
      bufferChanged()
      return true
    }
    return false
  }

  // Handles the following events:
  //   newline: accept
  //   tab: accept
  //   backspace: remove last character
  //   escape: deactivate (insert composition as-is)
  override func didCommand(by aSelector: Selector!, client sender: Any!) -> Bool {
    if isActive() {
      if aSelector == #selector(NSStandardKeyBindingResponding.insertNewline(_:)) ||
        aSelector == #selector(NSStandardKeyBindingResponding.insertTab(_:)) {
        accept()
        return true
      } else if aSelector == #selector(NSStandardKeyBindingResponding.deleteBackward(_:)) {
        compositionBuffer.remove(at: compositionBuffer.index(before: compositionBuffer.endIndex))
        bufferChanged()
        return true
      } else if aSelector == #selector(NSStandardKeyBindingResponding.cancelOperation(_:)) {
        deactivate()
        return true
      }
    }
    deactivate()
    return false
  }

  // Called by the system when the client wants to end composition immediately
  // (e.g. the user selected a new input method, or clicked outside of the marked
  // text).
  override func commitComposition(_ sender: Any!) {
    deactivate()
  }

  // Returns the menu that appears in the menu bar.
  override func menu() -> NSMenu {
    return mainMenu
  }

  // Called when the "Preferences..." menu item is selected.
  override func showPreferences(_ sender: Any!) {
    // TODO: implement
    NSLog("showPreferences")
  }
}
