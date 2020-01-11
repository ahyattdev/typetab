@class BrowserController, TabController, TabDocument, Application;
@class TabOverview, TiltedTabView;

@class UIView;

@protocol TabCollectionView;

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

@interface TabController: NSObject

// Called when the + button in the TiltedTabView on iPhone is pressed
- (void)_addNewActiveTiltedTabViewTab;
// Returns the currently displayed TabDocument
- (TabDocument *)activeTabDocument;

// nil when tab collection not presented
@property (retain) UIView<TabCollectionView> *tabCollectionView;

// iPhone portrait
@property (retain) TiltedTabView *tiltedTabView;

// iPhone landscape or iPad
@property (retain) TabOverview *tabOverview;

@end

@interface Application: UIApplication

- (BrowserController *)primaryBrowserController;

@end

// iPhone tab view in portrait
@interface TiltedTabView: UIView

// 2: showing
// 1: unknown
// 0: not showing
@property NSUInteger presentationState;

@end

// iPhone tab view in landscape, maybe iPad too?
@interface TabOverview

@end

%group 13

bool tabViewShowing13()
{
	BrowserController *bc = [(Application *)[UIApplication sharedApplication] primaryBrowserController];
	if (bc == nil)
	{
		return YES;
	}
	TabController *tc = [bc tabController];
	if (tc == nil)
	{
		return YES;
	}
	return [tc tabCollectionView] != nil;
}

void typeTab13()
{
	/*
	BrowserController *bc = [(Application *)[UIApplication sharedApplication] primaryBrowserController];
	TabController *tc = [bc tabController];
	TabDocument *activeTabDocument = [tc activeTabDocument];
	if (tc != nil && [activeTabDocument isBlankDocument])
	{
		NSLog(@"Tapping bar!");
		[bc navigationBarURLWasTapped:nil];
	}
	*/

}
%hook Application

// Show keyboard on launch if the current tab is blank
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  BOOL orig = %orig;
  if (!tabViewShowing13())
  {
  	typeTab13();
  }
  return orig;
}

// Show keyboard on resume if the current tab is blank
- (void)applicationDidBecomeActive:(UIApplication *)application {
  %orig;
  if (!tabViewShowing13())
  {
	typeTab13();
  }
}

// 3D Touch shortcut support
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL succeeded))completionHandler {
  %orig;
  if ([shortcutItem.type isEqualToString:@"com.apple.mobilesafari.shortcut.openNewTab"] || [shortcutItem.type isEqualToString:@"com.apple.mobilesafari.shortcut.openNewPrivateTab"]) {
    typeTab13();
  }
}

%end

// Called on iPad
%hook BrowserController

- (void)addTabFromButtonBar {
  %orig;
  typeTab13();
}

%end

// Called on iPhone
%hook TabController

- (void)_newTabFromTabViewButton {
  %orig;
  typeTab13();
}

%end

%end

%ctor {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 13.0) {
            %init(13);
        }
}
