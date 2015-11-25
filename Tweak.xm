@class Application, BrowserController, TabController, TabDocument;

@interface Application

// Returns the current Application
+ (instancetype)sharedApplication;
// Called when the app resumes from the background
- (void)applicationDidBecomeActive:(UIApplication *)application;
// Called when the app finishes launching
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
// Implemented by this tweak
// Brings up the keyboard
- (void)typeTab;

@end

@interface BrowserController

// Returns the current BrowserController
+ (instancetype)sharedBrowserController;
// Brings up the keyboard, use of arg1 us unknown
- (void)navigationBarURLWasTapped:(id)arg1;
// Called on iPad?
- (void)addTabFromButtonBar;
// Returns the current TabController
- (TabController *)tabController;
// Gets the state of private browsing
- (BOOL)privateBrowsingEnabled;
//Determins of the tab view is currently showing
- (BOOL)isShowingTabView;

@end

@interface TabController

// Called when the + button in the TiltedTabView on iPhone is pressed
- (void)_addNewActiveTiltedTabViewTab;
// Returns the currently displayed TabDocument
- (TabDocument *)activeTabDocument;
// Returns the currently loaded TabDocuments
- (NSArray *)currentTabDocuments;

@end

@interface TabDocument

// Returns if the document is blank or not
- (BOOL)isBlankDocument;

@end

%hook Application

%new
- (void)typeTab {
  if ([[%c(BrowserController) sharedBrowserController] tabController].activeTabDocument.isBlankDocument && ![[%c(BrowserController) sharedBrowserController] isShowingTabView]) {
    [[%c(BrowserController) sharedBrowserController] navigationBarURLWasTapped:nil];
  }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  %orig;
  [self typeTab];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  BOOL orig = %orig;
  [self typeTab];
  return orig;
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
