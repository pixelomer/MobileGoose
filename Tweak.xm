#import <UIKit/UIKit.h>
#import <Goose/MGGooseView.h>
#import <Goose/MGViewController.h>
#import <Goose/MGGooseController.h>

@interface MGWindow : UIWindow
@end

@interface SpringBoard : NSObject
- (BOOL)isLocked;
@end

static CGAffineTransform transform;
static UIWindow *gooseWindow;
static NSArray *honks;
static NSPointerArray *containers;
static MGViewController *viewController;

CGAffineTransform MGGetTransform(void) {
	return transform;
}

%subclass MGWindow : UIWindow

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	UIView *viewAtPoint = [self.rootViewController.view hitTest:point withEvent:event];
	if (!viewAtPoint || (viewAtPoint == self.rootViewController.view)) return NO;
	else return YES;
}

%end

%hook MGViewController

- (void)activeInterfaceOrientationDidChangeToOrientation:(long long)arg1 willAnimateWithDuration:(double)arg2 fromOrientation:(long long)arg3 {
	transform = [self transformForOrientation:arg1];
	for (UIView *view in viewController.view.subviews) {
		view.transform = transform;
	}
	[UIView animateWithDuration:0.5 animations:^{
		self.view.alpha = 1.0;
	}];
}

- (void)activeInterfaceOrientationWillChangeToOrientation:(long long)arg1 {
	[UIView animateWithDuration:0.5 animations:^{
		self.view.alpha = 0.0;
	}];
}

%end

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
	%orig;
	viewController = [MGViewController new];
	transform = [viewController transformForOrientation:UIInterfaceOrientationPortrait];
	gooseWindow = (UIWindow *)[[%c(MGWindow) alloc] initWithFrame:UIScreen.mainScreen.bounds];
	gooseWindow.screen = [UIScreen mainScreen];
	gooseWindow.rootViewController = viewController;
	gooseWindow.userInteractionEnabled = YES;
	gooseWindow.opaque = NO;
	gooseWindow.hidden = NO;
	gooseWindow.backgroundColor = [UIColor clearColor];
	gooseWindow.windowLevel = CGFLOAT_MAX - 1;
	[gooseWindow makeKeyAndVisible];
	containers = [NSPointerArray weakObjectsPointerArray];
	NSMutableArray *mHonks = [NSMutableArray new];
	const NSInteger gooseCount = 1;
	for (NSInteger i=0; i<gooseCount; i++) {
		CGRect frame = CGRectMake(0, 0, 0, 0);
		MGGooseView *honk = [[MGGooseView alloc] initWithFrame:frame];
		MGGooseController *controller = [[MGGooseController alloc] initWithGoose:honk];
		frame.size = [honk sizeThatFits:frame.size];
		frame.origin = CGPointMake(
			arc4random_uniform(gooseWindow.frame.size.width - frame.size.width),
			arc4random_uniform(gooseWindow.frame.size.height - frame.size.height)
		);
		honk.frame = frame;
		honk.shouldRenderFrameBlock = ^BOOL(MGGooseView *_gooseView){
			return !(
				[(SpringBoard *)UIApplication.sharedApplication isLocked] ||
				![(PrefValue(@"Enabled") ?: @YES) boolValue]
			);
		};
		[gooseWindow.rootViewController.view addSubview:honk];
		honk.layer.zPosition = 100;
		[mHonks addObject:honk];
		honk.facingTo = 0.0;
		[controller startLooping];

		// Causes a retain cycle, but MGGooseViews are never deallocated so it's fine
		objc_setAssociatedObject(honk, @selector(controller), controller, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	honks = mHonks.copy;
	mHonks = nil;
}

%end

static void MGResetPreferences(
	CFNotificationCenterRef center,
	void *observer,
	CFNotificationName name,
	const void *object,
	CFDictionaryRef userInfo
) {
	void(^block)() = ^{gooseWindow.hidden = ![(PrefValue(@"Enabled") ?: @YES) boolValue];};
	if ([NSThread isMainThread]) block();
	else dispatch_async(dispatch_get_main_queue(), block);
}

%ctor {
	CFNotificationCenterAddObserver(
		CFNotificationCenterGetDarwinNotifyCenter(),
		NULL,
		&MGResetPreferences,
		CFSTR("com.pixelomer.mobilegoose/PreferenceChange"),
		NULL,
		0
	);
	NSString *dir = @"/Library/Application Support/MobileGoose/Mods";
	NSArray *mods = [NSFileManager.defaultManager
		contentsOfDirectoryAtPath:dir
		error:nil
	];
	for (NSString *filename in mods) {
		NSString *fullFilePath = [dir stringByAppendingPathComponent:filename];
		dlopen(fullFilePath.UTF8String, RTLD_LAZY);
	}
}