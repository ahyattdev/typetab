@interface BrowserController

- (void)navigationBarURLWasTapped:(id)fp8;

@end

%hook TabController

- (void)_addNewActiveTiltedTabViewTab {
    %orig;
    BrowserController *bc = MSHookIvar<BrowserController *>([UIApplication sharedApplication], "_browserController");
    [bc navigationBarURLWasTapped:0];
}

%end
