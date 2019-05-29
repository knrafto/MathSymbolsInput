//
//  Replacements.h
//  UnicodeInput
//
//  Created by Kyle Raftogianis on 5/29/19.
//  Copyright © 2019 Kyle Raftogianis. All rights reserved.
//

#ifndef Replacements_h
#define Replacements_h

#import <Foundation/Foundation.h>

// Initializes the replacements module. This will start a background thread
// to watch the replacement file for changes.
void InitReplacements(void);

// Get the currently-loaded replacements for a given key.
NSArray* getReplacements(NSString* key);

#endif /* Replacements_h */
