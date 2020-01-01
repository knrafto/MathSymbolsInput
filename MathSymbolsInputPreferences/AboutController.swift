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

  @IBAction func visitHomepage(_ sender: Any) {
    NSWorkspace.shared.open(URL(string: "https://github.com/knrafto/MathSymbolsInput")!)
  }

  @IBAction func checkForUpdates(_ sender: Any) {
    NSWorkspace.shared.open(URL(string: "https://github.com/knrafto/MathSymbolsInput#Installation")!)
  }
}
