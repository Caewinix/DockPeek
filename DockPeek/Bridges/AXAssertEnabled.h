#ifndef AXAssertEnabled_h
#define AXAssertEnabled_h
#import <ApplicationServices/ApplicationServices.h>

/// Check if the accessibility is enabled for this application. It may need to delete the "Sandbox" box from the "Signing & Capabilities" tab, then uncheck "Automatically manage signing", select "Mac Developer" in "Signing Certificate", and then run the program, it will pop up the window of accessibility permission, and then check "Automatically manage signing" and run, the accessibility permission will also show.
void AXAssertEnabled() {
#if (MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_9)
    AXAPIEnabled();
#else
    NSDictionary *options = @{(id)CFBridgingRelease(kAXTrustedCheckOptionPrompt) : @YES};
    AXIsProcessTrustedWithOptions((CFDictionaryRef)options);
#endif
}

#endif
