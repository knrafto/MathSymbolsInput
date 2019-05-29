//
//  Replacements.m
//  UnicodeInput
//
//  Created by Kyle Raftogianis on 5/29/19.
//  Copyright © 2019 Kyle Raftogianis. All rights reserved.
//

#import <Foundation/Foundation.h>

NSDictionary* volatile replacementMap;

void InitReplacements(void) {
  replacementMap = @{
    @"\\to" : @[ @"→" ],
    @"\\Sigma" : @[ @"Σ" ],
    @"\\Pi" : @[ @"Π" ],
    @"\\bN" : @[ @"ℕ" ],
    @"\\r" : @[
      @"→", @"⇒", @"⇛", @"⇉", @"⇄", @"↦", @"⇨", @"↠", @"⇀", @"⇁",
      @"⇢", @"⇻", @"↝", @"⇾", @"⟶", @"⟹", @"↛", @"⇏", @"⇸", @"⇶",
    ],
  };
}

NSArray* getReplacements(NSString* key) {
  NSArray* replacements = replacementMap[key];
  return replacements != nil ? replacements : @[];
}
