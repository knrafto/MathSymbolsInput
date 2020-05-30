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
    // macOS Catalina seems to have a bug where registering an input source in this way won't
    // start it, leaving it broken until the user reboots. Starting it ourselves seems to fix
    // this though.
    [[NSWorkspace sharedWorkspace] openURL:(__bridge NSURL*) url];
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
    NSString *messageText = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"UpdateMessage" value:nil table:nil];
    [[self message] setStringValue:messageText];
    [[self yesEnableButton] setHidden:YES];
    [[self noEnableButton] setHidden:YES];
    [[self helpLink] setHidden:YES];
  } else {
    NSLog(@"Input source %@ is not yet enabled", kSourceID);
    NSString *messageText = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"EnableMessage" value:nil table:nil];
    [[self message] setStringValue:messageText];
  }
}

- (NSString *)title {
  return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"PaneTitle" value:nil table:nil];
}

// Called when the enable choice changes. Radio buttons with the same
// action are grouped together, so this puts them in the same group.
- (IBAction)enableChanged:(id)sender {}

- (void)willExitPane:(InstallerSectionDirection)dir {
  if (!isUpgrade && dir == InstallerDirectionForward) {
    registerInputMethod();
    if ([[self yesEnableButton] state] == NSControlStateValueOn) {
      enableInputMethod();
    }
  }
}
@end
