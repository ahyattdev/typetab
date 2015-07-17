@class TabDocument, TiltedTabView, BrowserController, BrowserControllerWK2, Application, TabController;

@interface BrowserController

- (void)navigationBarURLWasTapped:(id)fp8;
- (BOOL)isShowingFavorites;
- (BOOL)privateBrowsingEnabled;

@end

@interface BrowserControllerWK2

- (void)addTabFromButtonBar;

@end

@interface Application

- (void)typeTab;

@end

@interface TabController

- (NSArray *)_currentTabs;
- (TiltedTabView *)tiltedTabView;
- (void)_addNewActiveTiltedTabViewTab;

@end

@interface TiltedTabView

- (NSArray *)items;

@end

%hook Application

%new
- (void)typeTab {
    // Adds a method for typing into the search field to Safari's app delegate
    BrowserController *bc = MSHookIvar<BrowserController *>(self, "_controller");
    if ([bc isShowingFavorites]) {
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
