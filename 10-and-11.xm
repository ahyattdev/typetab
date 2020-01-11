@class BrowserController, TabController, TabDocument, Application;

@interface BrowserController

// Brings up the keyboard, use of arg1 us unknown
- (void)navigationBarURLWasTapped:(id)arg1;
//Determins of the tab view is currently showing
- (BOOL)isShowingTabView;
// Returns the current TabController
- (TabController *)tabController;
// Called on iPad?
- (void)addTabFromButtonBar;

@end

@interface TabDocument

// Returns if the document is blank or not
- (BOOL)isBlankDocument;

@end

@interface TabController

// Called when the + button in the TiltedTabView on iPhone is pressed
- (void)_addNewActiveTiltedTabViewTab;
// Returns the currently displayed TabDocument
- (TabDocument *)activeTabDocument;

@end

@interface Application

- (BrowserController *)_focusedBrowserController;

@end

// Handy macro for accessing the browser controller
#define BC [(Application *)[UIApplication sharedApplication] _focusedBrowserController]

#define TYPETAB() if ([[[BC tabController] activeTabDocument] isBlankDocument] && ![BC isShowingTabView]) [BC navigationBarURLWasTapped:nil]

%group 10and11

%hook Application

// Show keyboard on launch if the current tab is blank
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  BOOL orig = %orig;
  TYPETAB();
  return orig;
}

// Show keyboard on resume if the current tab is blank
- (void)applicationDidBecomeActive:(UIApplication *)application {
  %orig;
  TYPETAB();
}

// 3D Touch shortcut support
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL succeeded))completionHandler {
  %orig;
  if ([shortcutItem.type isEqualToString:@"com.apple.mobilesafari.shortcut.openNewTab"] || [shortcutItem.type isEqualToString:@"com.apple.mobilesafari.shortcut.openNewPrivateTab"]) {
    TYPETAB();
  }
}

%end

// Called on iPad
%hook BrowserController

- (void)addTabFromButtonBar {
  %orig;
  TYPETAB();
}

%end

// Called on iPhone
%hook TabController

- (void)_addNewActiveTiltedTabViewTab {
  %orig;
  TYPETAB();
}

%end

%end

%ctor {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0 && [[[UIDevice currentDevice] systemVersion] floatValue] < 12.0) {
            %init(10and11);
        }
}
