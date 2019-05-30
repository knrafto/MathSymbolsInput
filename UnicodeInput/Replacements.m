//
//  Replacements.m
//  UnicodeInput
//
//  Created by Kyle Raftogianis on 5/29/19.
//  Copyright © 2019 Kyle Raftogianis. All rights reserved.
//

#include <assert.h>
#include <pthread.h>

#import <Foundation/Foundation.h>

NSDictionary* volatile replacementMap;

@interface BackgroundThread : NSObject
@end

@implementation BackgroundThread

+ (void)run:(id)param {
  NSLog(@"Started background thread");
}

@end

void initReplacements(void) {
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

  [NSThread detachNewThreadSelector:@selector(run:)
                           toTarget:[BackgroundThread class]
                         withObject:nil];
}

NSArray* getReplacements(NSString* key) {
  NSArray* replacements = replacementMap[key];
  return replacements != nil ? replacements : @[];
}
