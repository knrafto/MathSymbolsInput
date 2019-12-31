//
//  HyperlinkTextField.m
//  InstallerActivatePane
//
//  Created by Kyle Raftogianis on 12/30/19.
//  Copyright © 2019 Kyle Raftogianis. All rights reserved.
//

#import "HyperlinkTextField.h"

IB_DESIGNABLE
@implementation HyperlinkTextField

- (void)awakeFromNib {
  [super awakeFromNib];

  NSMutableAttributedString *hyperlink = [[NSMutableAttributedString alloc] initWithAttributedString:[self attributedStringValue]];
  NSRange range = NSMakeRange(0, [hyperlink length]);

  [hyperlink addAttribute:NSLinkAttributeName value:[self href] range:range];
  [hyperlink addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:range];
  [hyperlink addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:range];

  [self setAttributedStringValue:hyperlink];
}

- (void)resetCursorRects {
  [self discardCursorRects];
  [self addCursorRect:[self bounds] cursor:[NSCursor pointingHandCursor]];
}

- (void)mouseDown:(NSEvent *)event {
  NSURL *url = [NSURL URLWithString:[self href]];
  if (url != NULL) {
    [[NSWorkspace sharedWorkspace] openURL:url];
  }
}

@end
