//
//  ActivatePane.m
//  InstallerActivatePane
//
//  Created by Kyle Raftogianis on 12/30/19.
//  Copyright © 2019 Kyle Raftogianis. All rights reserved.
//

#import "ActivatePane.h"

@implementation ActivatePane

- (NSString *)title
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"PaneTitle" value:nil table:nil];
}

- (void)didEnterPane:(InstallerSectionDirection)dir
{
    NSLog(@"ActivatePane");
}

@end
