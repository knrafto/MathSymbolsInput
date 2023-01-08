#import <Carbon/Carbon.h>

static const char *kInstallLocation = "/Library/Input Methods/Math Symbols Input.app";
static NSString *kProcessName = @"Math Symbols Input";
static NSString *kSourceID = @"com.mathsymbolsinput.inputmethod.MathSymbolsInput";

static void logIfError(OSStatus status, NSString *message) {
  if (status != noErr) {
    NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
    NSLog(@"%@: %@", message, [error localizedDescription]);
  }
}

// Enables and selects the input method after an install or upgrade.
//
// We sleep for a bit between steps because it seems like many things happen in
// the background, and if we do some steps too quickly then things could be
// left in an inconsistent state.
int main(int argc, const char *argv[]) {
  @autoreleasepool {

    // Running as root won't actually activate the input method and seems to
    // leave things broken until the next reboot.
    if (geteuid() == 0) {
      NSLog(@"Activate script should not be run as root, aborting");
      return 1;
    }

    CFURLRef url = CFURLCreateFromFileSystemRepresentation(NULL, (const UInt8 *) kInstallLocation, strlen(kInstallLocation), NO);
    NSLog(@"Registering input source %s", kInstallLocation);
    logIfError(TISRegisterInputSource(url), @"Could not register input source");
    CFRelease(url);
    [NSThread sleepForTimeInterval:1.0];

    // Find our input method.
    TISInputSourceRef inputMethod = nil;
    CFArrayRef inputSources = TISCreateInputSourceList(NULL, YES);
    for (int i = 0; i < CFArrayGetCount(inputSources); i++) {
      TISInputSourceRef inputSource = (TISInputSourceRef) CFArrayGetValueAtIndex(inputSources, i);
      NSString *sourceID = (__bridge NSString *) TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceID);
      if ([sourceID isEqualToString:kSourceID]) {
        inputMethod = inputSource;
        break;
      }
    }
    if (inputMethod == nil) {
      NSLog(@"Could not find input source %@", kSourceID);
      return 1;
    }

    // We shouldn't kill an input method while it's active, so we disable it first.
    if (CFBooleanGetValue(TISGetInputSourceProperty(inputMethod, kTISPropertyInputSourceIsEnabled))) {
      NSLog(@"Disabling input source %@", kSourceID);
      logIfError(TISDisableInputSource(inputMethod), @"Could not disable input source");
      [NSThread sleepForTimeInterval:1.0];
    }

    // We have to kill the old process for the new version to take effect. The
    // new process will be started automatically.
    NSLog(@"Killing process %@", kProcessName);
    NSTask *task = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/killall" arguments:@[kProcessName]];
    [task waitUntilExit];
    [NSThread sleepForTimeInterval:1.0];

    NSLog(@"Enabling input source %@", kSourceID);
    logIfError(TISEnableInputSource(inputMethod), @"Could not enable input source");
    [NSThread sleepForTimeInterval:1.0];

    NSLog(@"Selecting input source %@", kSourceID);
    logIfError(TISSelectInputSource(inputMethod), @"Could not select input source");

    CFRelease(inputSources);
  }
  return 0;
}
