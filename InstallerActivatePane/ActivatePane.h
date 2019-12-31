//
//  ActivatePane.h
//  InstallerActivatePane
//
//  Created by Kyle Raftogianis on 12/30/19.
//  Copyright © 2019 Kyle Raftogianis. All rights reserved.
//

#import <InstallerPlugins/InstallerPlugins.h>
#import "HyperlinkTextField.h"

@interface ActivatePane : InstallerPane {
  // Whether the input method was previously installed.
  BOOL isUpgrade;
  // Whether to automatically enable.
  BOOL shouldEnable;
}

@property (weak) IBOutlet NSTextField *message;
@property (weak) IBOutlet NSButton *yesEnableButton;
@property (weak) IBOutlet NSButton *noEnableButton;
@property (weak) IBOutlet HyperlinkTextField *helpLink;

@end
