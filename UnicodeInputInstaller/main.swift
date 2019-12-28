//
//  main.swift
//  UnicodeInputInstaller
//
//  Created by Kyle Raftogianis on 12/28/19.
//  Copyright © 2019 Kyle Raftogianis. All rights reserved.
//

import Foundation
import Carbon

func checkStatus(_ status: OSStatus) {
  if status == noErr {
    return
  }

  let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
  print("ERROR:", error.localizedDescription)
  exit(1)
}

// Register the input source.
let installPath = "Library/Input Methods/UnicodeInput.app"
print("Registering input source from ~/\(installPath)")
checkStatus(TISRegisterInputSource(URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent(installPath) as CFURL))

// Find the input source and enable it.
let inputSourceId = "com.knrafto.inputmethod.UnicodeInput"
let properties: NSDictionary = [
  kTISPropertyInputSourceID! : inputSourceId,
]

let inputSources = TISCreateInputSourceList(properties, true)?.takeRetainedValue() as! [TISInputSource?]
if inputSources.isEmpty {
  print("No input source with id", inputSourceId)
  exit(1)
}
let inputSource = inputSources[0]!

print("Enabling input source", inputSourceId)
checkStatus(TISEnableInputSource(inputSource))
print("Selecting input source", inputSourceId)
checkStatus(TISSelectInputSource(inputSource))
