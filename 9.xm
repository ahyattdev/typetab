@class Application, BrowserController, TabController, TabDocument, TiltedTabView;

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
// Returns the tilted tab view if running on an iPhone
- (TiltedTabView *)tiltedTabView;

@end

@interface TabDocument

// Returns if the document is blank or not
- (BOOL)isBlankDocument;

@end

// iOS 9.0+ code
%group 9

%hook Application

// Shows the keyboard if the current tab is blank
%new
- (void)typeTab {
  if ([[%c(BrowserController) sharedBrowserController] tabController].activeTabDocument.isBlankDocument && ![[%c(BrowserController) sharedBrowserController] isShowingTabView]) {
    [[%c(BrowserController) sharedBrowserController] navigationBarURLWasTapped:nil];
  }
}

// Show keyboard on resume if the current tab is blank
- (void)applicationDidBecomeActive:(UIApplication *)application {
  %orig;
  [self typeTab];
}

// Show keyboard on launch if the current tab is blank
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  BOOL orig = %orig;
  [self typeTab];
  return orig;
}

// 3D Touch shortcut support
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL succeeded))completionHandler {
  %orig;
  if ([shortcutItem.type isEqualToString:@"com.apple.mobilesafari.shortcut.openNewTab"] || [shortcutItem.type isEqualToString:@"com.apple.mobilesafari.shortcut.openNewPrivateTab"]) {
    [[%c(BrowserController) sharedBrowserController] navigationBarURLWasTapped:nil];
  }
}

%end

// Called on iPad
%hook BrowserController

- (void)addTabFromButtonBar {
  %orig;
  [[%c(Application) sharedApplication] typeTab];
}

%end

// Called on iPhone
%hook TabController

- (void)_addNewActiveTiltedTabViewTab {
  %orig;
  [[%c(Application) sharedApplication] typeTab];
}

%end

%end

%ctor {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0 &&
        [[[UIDevice currentDevice] systemVersion] floatValue] < 10.0) {
            %init(9);
        }
}
