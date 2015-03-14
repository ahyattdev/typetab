@interface BrowserController

- (void)navigationBarURLWasTapped:(id)fp8;

@end

@interface Application

- (void)typeTab;

@end

%hook Application

%new
- (void)typeTab {
    // Adds a method for typing into the search field to Safari's app delegate
    BrowserController *bc = MSHookIvar<BrowserController *>(self, "_controller");
    [bc navigationBarURLWasTapped:0];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    %orig;
    [(Application *)[UIApplication sharedApplication] typeTab];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    %orig;
    [(Application *)[UIApplication sharedApplication] typeTab];
}

%end

%hook TabController

- (void)_addNewActiveTiltedTabViewTab {
    // Called when you press the add tab UIBarButtonItem on iPhone
    %orig;
    [(Application *)[UIApplication sharedApplication] typeTab];
}

%end

%hook BrowserControllerWK2

- (void)addTabFromButtonBar {
    // Called when you press the add tab UIBarButtonItem on iPad
    %orig;
    [(Application *)[UIApplication sharedApplication] typeTab];
}

%end

%hook BrowserRootViewController

- (void)_newTabKeyPressed {
    // Called when Command+T is pressed on a hardware keyboard
    %orig;
    [(Application *)[UIApplication sharedApplication] typeTab];
}

%end