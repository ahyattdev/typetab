@class BrowserController, TabController, TabDocument, Application;
@class TabOverview, TiltedTabView;

@class UIView;

@protocol TabCollectionView;

@interface BrowserController

// Brings up the keyboard, use of arg1 us unknown
- (void)navigationBarURLWasTapped:(id)arg1 completionHandler:(id)arg2;
//Determins of the tab view is currently showing
- (BOOL)isShowingTabView;
// Returns the current TabController
- (TabController *)tabController;
@end

@interface TabDocument

// Returns if the document is blank or not
- (BOOL)isBlank;

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

@interface BrowserRootViewController: UIViewController
@end
@interface BookmarkFavoritesViewController: UIViewController
@end

%group 14

bool tabViewShowing14()
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

void typeTab14()
{
	BrowserController *bc = [(Application *)[UIApplication sharedApplication] primaryBrowserController];
	TabController *tc = [bc tabController];
	TabDocument *activeTabDocument = [tc activeTabDocument];
	if(activeTabDocument == nil){
		return;
	}
	if (tc != nil && MSHookIvar<BOOL>(activeTabDocument, "_isBlank"))//*
	{
		NSLog(@"Tapping bar!");
		[bc navigationBarURLWasTapped:nil completionHandler:nil];
	}
}

void typeTabAssumeBlank14()
{
	BrowserController *bc = [(Application *)[UIApplication sharedApplication] primaryBrowserController];
	[bc navigationBarURLWasTapped:nil completionHandler:nil];
}

%hook BrowserRootViewController

- (void)viewDidAppear:(BOOL)animated
{
	%orig;
	if (!tabViewShowing14())
	{
		typeTab14();
	}
}

%end

%hook BookmarkFavoritesViewController

- (void)viewDidAppear:(BOOL)animated
{
	%orig;
	if (!tabViewShowing14())
	{
		typeTab14();
	}
}

%end

%hook BrowserController

- (void)tabController:(TabController *)tc didSwitchFromTabDocument:(TabDocument *)oldTab toTabDocument:(TabDocument *)newTab
{
	%orig;
	if ([newTab isBlank])
	{
		typeTabAssumeBlank14();
	}
}

- (void)tabDocumentCommitPreviewedDocument:(TabDocument *)tabDoc
{
	%orig;
	if ([tabDoc isBlank])
	{
		typeTabAssumeBlank14();
	}
}

// TODO: this class handles command+n

%end

// Called on iPhone
%hook TabController

- (void)_newTabFromTabViewButton
{
  %orig;
  typeTabAssumeBlank14();
}

- (void)_addNewActiveTabOverviewTab
{
  %orig;
  typeTabAssumeBlank14();
}

- (void)_addNewActiveTiltedTabViewTab
{
  %orig;
  typeTabAssumeBlank14();
}

- (void)newTab
{
	%orig;
	typeTab14();
}

%end

%hook TiltedTabView

- (void)activateItem:(id)arg0
{
	%orig;
	typeTab14();
}

%end

%hook TabOverview

- (void)activateItem:(id)arg0
{
	%orig;
	typeTab14();
}

- (void)_activateItemToActivate
{
	%orig;
	typeTab14();
}

%end

%end

%ctor {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 14.0) {
            %init(14);
        }
}
