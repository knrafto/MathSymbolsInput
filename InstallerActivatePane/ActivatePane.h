#import <InstallerPlugins/InstallerPlugins.h>
#import "HyperlinkTextField.h"

@interface ActivatePane : InstallerPane

@property (weak) IBOutlet NSTextField *message;
@property (weak) IBOutlet NSButton *yesEnableButton;
@property (weak) IBOutlet NSButton *noEnableButton;
@property (weak) IBOutlet HyperlinkTextField *helpLink;

@end
