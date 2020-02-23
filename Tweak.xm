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
static NSDictionary<NSString *, NSBundle *> *modBundles;
static NSDictionary<NSString *, NSArray<NSObject<MGMod> *> *> *allModObjects;

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
	gooseWindow.windowLevel = CGFLOAT_MAX / 2.0;
	[gooseWindow makeKeyAndVisible];
	containers = [NSPointerArray weakObjectsPointerArray];
	NSMutableArray *mHonks = [NSMutableArray new];
	const NSInteger gooseCount = 1;
	NSMutableDictionary *modObjects = [NSMutableDictionary new];
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
			BOOL disabled = (
				[(SpringBoard *)UIApplication.sharedApplication isLocked] ||
				![(PrefValue(@"Enabled") ?: @YES) boolValue]
			);
			gooseWindow.userInteractionEnabled = !disabled;
			gooseWindow.hidden = disabled;
			return !disabled;
		};
		[gooseWindow.rootViewController.view addSubview:honk];
		honk.layer.zPosition = 100;
		[mHonks addObject:honk];
		honk.facingTo = 0.0;
		[controller startLooping];
		
		// Initialize mods
		NSArray *mods;
		NSMutableArray *mMods = [NSMutableArray new];
		for (NSBundle *bundle in modBundles.allValues) {
			__kindof NSObject<MGMod> *mod = [bundle.principalClass alloc];
			if ([mod respondsToSelector:@selector(initWithGoose:bundle:)]) {
				mod = [mod initWithGoose:honk bundle:bundle];
			}
			else if ([mod respondsToSelector:@selector(initWithGoose:)]) {
				mod = [mod initWithGoose:honk];
			}
			else {
				mod = [mod init];
			}
			if (mod) {
				[mMods addObject:mod];
				if ([mod respondsToSelector:@selector(enabled)]) {
					mod.enabled = [(NSNumber *)([NSUserDefaults.standardUserDefaults
						objectForKey:@"Enabled"
						inDomain:bundle.bundleIdentifier
					] ?: @YES) boolValue];
				}
			}
			if (!modObjects[bundle.bundlePath]) {
				modObjects[bundle.bundlePath] = [NSMutableArray new];
			}
			NSMutableArray *array = modObjects[bundle.bundlePath];
			[array addObject:mod];
		}
		mods = mMods.copy;
		mMods = nil;
		objc_setAssociatedObject(honk, @selector(mods), mods, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

		// Make the goose notify its mods
		[honk addFrameHandler:^(MGGooseView *sender, MGGooseFrameState state){
			NSArray *mods = objc_getAssociatedObject(sender, @selector(mods));
			for (__kindof NSObject<MGMod> *mod in mods) {
				if ([mod respondsToSelector:@selector(enabled)] && !mod.enabled) continue;
				if ([mod respondsToSelector:@selector(handleFrameInState:)]) {
					[mod handleFrameInState:state];
				}
			}
		}];

		// Causes a retain cycle, but MGGooseViews are never deallocated so it's fine
		objc_setAssociatedObject(honk, @selector(controller), controller, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}

	// Add preference observers
	for (NSString *key in modObjects.allKeys.copy) {
		modObjects[key] = [(NSObject *)modObjects[key] copy];
	}
	allModObjects = modObjects.copy;
	[[%c(NSDistributedNotificationCenter) defaultCenter]
		addObserverForName:@"com.pixelomer.mobilegoose/ModPreferencesChanged"
		object:nil
		queue:nil
		usingBlock:^(NSNotification *notification){
			NSArray *allRelatedObjects = allModObjects[notification.object];
			NSString *key = notification.userInfo[@"key"];
			id newValue = notification.userInfo[@"newValue"];
			for (NSObject<MGMod> *mod in allRelatedObjects) {
				if ([key isEqualToString:@"Enabled"]) {
					if ([mod respondsToSelector:@selector(enabled)]) {
						mod.enabled = [(NSNumber *)newValue boolValue];
					}
				}
				else if ([mod respondsToSelector:@selector(preferenceWithKey:didChangeToValue:)]) {
					[mod preferenceWithKey:key didChangeToValue:newValue];
				}
			}
		}
	];

	// Finalization
	honks = mHonks.copy;
	mHonks = nil;
	for (MGGooseView *honk in honks) {
		NSArray *mods = objc_getAssociatedObject(honk, @selector(mods));
		for (__kindof NSObject<MGMod> *mod in mods) {
			if ([mod respondsToSelector:@selector(springboardDidFinishLaunching::)]) {
				[mod springboardDidFinishLaunching:self];
			}
		}
	}
}

%end

static void MGResetPreferences(
	CFNotificationCenterRef center,
	void *observer,
	CFNotificationName name,
	const void *object,
	CFDictionaryRef userInfo
) {
	[NSUserDefaults.standardUserDefaults synchronize];
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
	NSString *dir = @"/Library/MobileGoose/Mods";
	NSArray *mods = [NSFileManager.defaultManager
		contentsOfDirectoryAtPath:dir
		error:nil
	];
	NSMutableDictionary *mModBundles = [NSMutableDictionary new];
	for (NSString *filename in mods) {
		NSString *fullFilePath = [dir stringByAppendingPathComponent:filename];
		NSBundle *bundle = [NSBundle bundleWithPath:fullFilePath];
		if ([bundle load]) {
			mModBundles[bundle.bundlePath] = bundle;
		}
	}
	modBundles = mModBundles.copy;
}