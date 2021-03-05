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
	BrowserController *bc = [(Application *)[UIApplication sharedApplication] primaryBrowserController];
	TabController *tc = [bc tabController];
	TabDocument *activeTabDocument = [tc activeTabDocument];
	if (tc != nil && [activeTabDocument isBlank])
	{
		NSLog(@"Tapping bar!");
		[bc navigationBarURLWasTapped:nil];
	}
}

void typeTabAssumeBlank13()
{
	BrowserController *bc = [(Application *)[UIApplication sharedApplication] primaryBrowserController];
	[bc navigationBarURLWasTapped:nil];
}

%hook BrowserRootViewController

- (void)viewDidAppear:(BOOL)animated
{
	%orig;
	if (!tabViewShowing13())
	{
		typeTab13();
	}
}

%end

%hook BookmarkFavoritesViewController

- (void)viewDidAppear:(BOOL)animated
{
	%orig;
	if (!tabViewShowing13())
	{
		typeTab13();
	}
}

%end

%hook BrowserController

- (void)tabController:(TabController *)tc didSwitchFromTabDocument:(TabDocument *)oldTab toTabDocument:(TabDocument *)newTab
{
	%orig;
	if ([newTab isBlank])
	{
		typeTabAssumeBlank13();
	}
}

- (void)tabDocumentCommitPreviewedDocument:(TabDocument *)tabDoc
{
	%orig;
	if ([tabDoc isBlank])
	{
		typeTabAssumeBlank13();
	}
}

// TODO: this class handles command+n

%end

// Called on iPhone
%hook TabController

- (void)_newTabFromTabViewButton
{
  %orig;
  typeTabAssumeBlank13();
}

- (void)_addNewActiveTabOverviewTab
{
  %orig;
  typeTabAssumeBlank13();
}

- (void)_addNewActiveTiltedTabViewTab
{
  %orig;
  typeTabAssumeBlank13();
}

- (void)newTab
{
	%orig;
	typeTab13();
}

%end

%hook TiltedTabView

- (void)activateItem:(id)arg0
{
	%orig;
	typeTab13();
}

%end

%hook TabOverview

- (void)activateItem:(id)arg0
{
	%orig;
	typeTab13();
}

- (void)_activateItemToActivate
{
	%orig;
	typeTab13();
}

%end

%end

%ctor {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 13.0 && [[[UIDevice currentDevice] systemVersion] floatValue] < 14.0) {
            %init(13);
        }
}
