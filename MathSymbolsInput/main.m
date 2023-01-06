#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>

#import "Commands.h"

// Unique connection name for this input method.
static NSString *kConnectionName = @"MathSymbolsInput_1_Connection";

int main(int argc, const char *argv[]) {
  loadDefaultCommands();
  // Server that accepts connections from client applications. It will create an
  // InputController instance to handle each client connection.
  IMKServer *server = [[IMKServer alloc] initWithName:kConnectionName bundleIdentifier:[[NSBundle mainBundle] bundleIdentifier]];
  (void) server;
  // Run the app.
  [[NSApplication sharedApplication] run];
  return 0;
}
