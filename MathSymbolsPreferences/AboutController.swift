//
//  AboutController.swift
//  MathSymbolsPreferences
//
//  Created by Kyle Raftogianis on 12/29/19.
//  Copyright © 2019 Kyle Raftogianis. All rights reserved.
//

import Foundation
import Cocoa

class AboutController : NSViewController {
  @IBOutlet weak var versionField: NSTextField!
  @IBOutlet weak var copyrightField: NSTextField!

  override func viewDidLoad() {
    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    if version != nil {
      versionField.stringValue = "Version " + version!
    }
    let copyright = Bundle.main.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as? String
    if copyright != nil {
      copyrightField.stringValue = copyright!
    }
  }
}
