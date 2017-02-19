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

@class TabDocument, TiltedTabView, BrowserController, BrowserControllerWK2, Application, TabController;

@interface TabController (Legacy)

- (NSArray *)_currentTabs;

@end

@interface TiltedTabView

- (NSArray *)items;

@end

// iOS 8.0-8.4.1 code
%group 8

%hook Application

%new
- (void)typeTab {
    // Adds a method for typing into the search field to Safari's app delegate
    BrowserController *bc = MSHookIvar<BrowserController *>(self, "_controller");

    if (bc.tabController.activeTabDocument.isBlankDocument) {
        [bc navigationBarURLWasTapped:0];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    %orig;
    [(Application *)[UIApplication sharedApplication] typeTab];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    %orig;
    BrowserController *bc = MSHookIvar<BrowserController *>(self, "_controller");
    if (!bc.privateBrowsingEnabled) {
        [(Application *)[UIApplication sharedApplication] typeTab];
    }
}

%end

%hook TabController

- (void)setActiveTabDocument:(TabDocument *)blankTab animated:(BOOL)animated {
    %orig;
    // Main hook for normal browsing
    BrowserController *bc = MSHookIvar<BrowserController *>(self, "_browserController");
    if (!bc.privateBrowsingEnabled) {
        [(Application *)[UIApplication sharedApplication] typeTab];
    }
}

// Done as a workaround to a bug with the private browsing TiltedTabView

- (void)_addNewActiveTiltedTabViewTab {
    Application *appDel = (Application *)[UIApplication sharedApplication];
    BrowserController *bc = MSHookIvar<BrowserController *>(appDel, "_controller");
    // Called when you press the add tab UIBarButtonItem on iPhone
    %orig;
    if (bc.privateBrowsingEnabled) {
        [(Application *)[UIApplication sharedApplication] typeTab];
    }
}

%end

%hook BrowserControllerWK2

- (void)addTabFromButtonBar {
    Application *appDel = (Application *)[UIApplication sharedApplication];
    BrowserController *bc = MSHookIvar<BrowserController *>(appDel, "_controller");
    // Called when you press the add tab UIBarButtonItem on iPad
    %orig;
    if (bc.privateBrowsingEnabled) {
        [(Application *)[UIApplication sharedApplication] typeTab];
    }
}

%end

%hook TabOverview

- (void)_addTab {
    %orig;
    // Also iPad
    Application *appDel = (Application *)[UIApplication sharedApplication];
    BrowserController *bc = MSHookIvar<BrowserController *>(appDel, "_controller");
    if (bc.privateBrowsingEnabled) {
        [(Application *)[UIApplication sharedApplication] typeTab];
    }
}

%end

%end

%ctor {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 &&
        [[[UIDevice currentDevice] systemVersion] floatValue] < 9.0) {
            %init(8);
        }
}
