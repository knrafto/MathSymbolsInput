//
//  HyperlinkTextField.h
//  InstallerActivatePane
//
//  Created by Kyle Raftogianis on 12/30/19.
//  Copyright © 2019 Kyle Raftogianis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface HyperlinkTextField : NSTextField
@property IBInspectable NSString *href;
@end

NS_ASSUME_NONNULL_END
