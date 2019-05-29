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

void* BackgroundThreadMain(void* data) {
  NSLog(@"Started background thread");
  return NULL;
}

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

  // Create a detached POSIX thread.
  pthread_attr_t attr;
  pthread_t threadId;

  assert(!pthread_attr_init(&attr));
  assert(!pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED));
  assert(!pthread_create(&threadId, &attr, &BackgroundThreadMain, NULL));
  assert(!pthread_attr_destroy(&attr));
}

NSArray* getReplacements(NSString* key) {
  NSArray* replacements = replacementMap[key];
  return replacements != nil ? replacements : @[];
}
