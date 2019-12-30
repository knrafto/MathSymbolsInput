//
//  ActivatePane.h
//  InstallerActivatePane
//
//  Created by Kyle Raftogianis on 12/30/19.
//  Copyright © 2019 Kyle Raftogianis. All rights reserved.
//

#import <InstallerPlugins/InstallerPlugins.h>

@interface ActivatePane : InstallerPane {
  // Whether the input method was previously installed.
  BOOL isUpgrade;
}
@end
