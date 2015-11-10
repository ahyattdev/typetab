@interface Application

// Returns the current Application
+ (instancetype)sharedApplication;
// Implemented by this tweak
- (void)typeTab;

@end

@interface BrowserController

// Brings up the keyboard, use of arg1 us unknown
- (void)navigationBarURLWasTapped:(id)arg1;
// Called on iPad?
- (void)addTabFromButtonBar;
// Returns the current BrowserController
+ (instancetype)sharedBrowserController;

@end

@interface TabController

// Called when the + button in the TiltedTabView on iPhone is pressed
- (void)_addNewActiveTiltedTabViewTab;

@end

%hook Application

%new
- (void)typeTab {
  NSLog(@"%@", [[%c(BrowserController) sharedBrowserController] description]);
  [[%c(BrowserController) sharedBrowserController] navigationBarURLWasTapped:nil];
}

%end

%hook BrowserController

- (void)addTabFromButtonBar {
  %orig;
  [[%c(Application) sharedApplication] typeTab];
}

%end

%hook TabController

- (void)_addNewActiveTiltedTabViewTab {
  %orig;
  [[%c(Application) sharedApplication] typeTab];
}

%end
