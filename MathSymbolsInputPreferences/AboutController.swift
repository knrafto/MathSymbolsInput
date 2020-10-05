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
  }

  @IBAction func visitHomepage(_ sender: Any) {
    NSWorkspace.shared.open(URL(string: "https://github.com/knrafto/MathSymbolsInput")!)
  }
}
