//
//  MyInstallerPane.m
//  InstallerActivatePane
//
//  Created by Kyle Raftogianis on 12/30/19.
//  Copyright © 2019 Kyle Raftogianis. All rights reserved.
//

#import "MyInstallerPane.h"

@implementation MyInstallerPane

- (NSString *)title
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"PaneTitle" value:nil table:nil];
}

@end
