//
//  ActivatePane.m
//  InstallerActivatePane
//
//  Created by Kyle Raftogianis on 12/30/19.
//  Copyright © 2019 Kyle Raftogianis. All rights reserved.
//

#import "ActivatePane.h"

#import <Carbon/Carbon.h>

static const char *kInstallLocation = "/Library/Input Methods/MathSymbolsInput.app";
static NSString *const kSourceID = @"com.mathsymbolsinput.inputmethod.MathSymbolsInput";

// Returns whether the input method is already registered.
static BOOL isInputMethodRegistered() {
  CFArrayRef inputSources = TISCreateInputSourceList(NULL, YES);
  for (int i = 0; i < CFArrayGetCount(inputSources); i++) {
    TISInputSourceRef inputSource = (TISInputSourceRef) CFArrayGetValueAtIndex(inputSources, i);
    NSString *sourceID = (__bridge NSString *) TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceID);
    if ([sourceID isEqualToString:kSourceID]) {
      CFBooleanRef isEnabled = (CFBooleanRef) TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceIsEnabled);
      if (CFBooleanGetValue(isEnabled)) {
        return YES;
      }
    }
  }
  return NO;
}

static void registerInputMethod() {
  CFURLRef url = CFURLCreateFromFileSystemRepresentation(NULL, (const UInt8 *) kInstallLocation, strlen(kInstallLocation), NO);
  if (url) {
    TISRegisterInputSource(url);
    NSLog(@"Registered input source from %s", kInstallLocation);
  }
}

static void enableInputMethod() {
  CFArrayRef inputSources = TISCreateInputSourceList(NULL, YES);
  for (int i = 0; i < CFArrayGetCount(inputSources); i++) {
    TISInputSourceRef inputSource = (TISInputSourceRef) CFArrayGetValueAtIndex(inputSources, i);
    NSString *sourceID = (__bridge NSString *) TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceID);
    if ([sourceID isEqualToString:kSourceID]) {
      TISEnableInputSource(inputSource);
      TISSelectInputSource(inputSource);
      NSLog(@"Enabled input source %@", kSourceID);
      return;
    }
  }
}

@implementation ActivatePane

- (void)awakeFromNib {
  isUpgrade = isInputMethodRegistered();
  if (isUpgrade) {
    NSLog(@"Input source %@ is already enabled", kSourceID);
  } else {
    NSLog(@"Input source %@ is not yet enabled", kSourceID);
  }
}

- (NSString *)title
{
  return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"PaneTitle" value:nil table:nil];
}

- (void)didEnterPane:(InstallerSectionDirection)dir
{
  // TODO: if upgrade, show message. Else, show option to enable.
  NSLog(@"ActivatePane didEnterPane");
}

- (void)willExitPane:(InstallerSectionDirection)dir
{
  if (!isUpgrade && dir == InstallerDirectionForward) {
    registerInputMethod();
    // TODO: only when user selects
    enableInputMethod();
  }
}

@end
