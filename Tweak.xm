#import <UIKit/UIKit.h>
#import <Goose/MGGooseView.h>
#import <Goose/MGTextContainerView.h>
#import <Goose/MGImageContainerView.h>
#import <Goose/MGViewController.h>

@interface NSUserDefaults(Private)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
@end

#define PrefValue(key) ([NSUserDefaults.standardUserDefaults \
	objectForKey:key \
	inDomain:@"com.pixelomer.mobilegoose" \
])

@interface MGWindow : UIWindow
@end

@interface SpringBoard : NSObject
- (BOOL)isLocked;
@end

static CGAffineTransform transform;
static UIWindow *gooseWindow;
static void(^animationHandler)(MGGooseView *);
static void(^animation2Handler)(MGGooseView *);
static void(^showMeme)(MGGooseView *);
static void(^walkHandler)(MGGooseView *);
static void(^findMeme)(MGGooseView *);
static void(^gotoMemeFrameHandler)(MGGooseView *, MGGooseFrameState state);
static void(^turnToMemeHandler)(MGGooseView *);
static void(^pullMemeFrameHandler)(MGGooseView *, MGGooseFrameState state);
static void(^finishMemeAnimation)(MGGooseView *);
static void(^turnToUserAnimation)(MGGooseView *);
static void(^loadMeme)(void);
static BOOL(^shouldRenderFrameBlock)(MGGooseView *sender);
static __kindof MGContainerView *imageContainer;
static BOOL getMemeFromTheLeft;
static NSInteger frameHandlerIndex;
static NSArray *honks;
static NSPointerArray *containers;
static MGViewController *viewController;
static const CGFloat defaultSpeed = 2.6;

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
	[gooseWindow.rootViewController.view addSubview:imageContainer];
	[gooseWindow makeKeyAndVisible];
	finishMemeAnimation = ^(MGGooseView *sender){
		[sender removeFrameHandlerAtIndex:frameHandlerIndex];
		sender.stopsAtEdge = YES;
		imageContainer = nil;
		turnToUserAnimation(sender);
	};
	loadMeme = ^{
		BOOL isImage = [imageContainer isKindOfClass:[MGImageContainerView class]];
		NSString *path = [NSString
			stringWithFormat:@"/Library/Application Support/MobileGoose/%@",
			isImage ? @"Memes" : @"Notes"
		];
		NSArray *files = [NSFileManager.defaultManager contentsOfDirectoryAtPath:path error:nil];
		if ([(((NSNumber *)PrefValue(@"DisableDefaultGifts")) ?: @NO) boolValue]) {
			NSMutableArray *mFiles = files.mutableCopy;
			[mFiles removeObject:@"DefaultMeme.png"];
			[mFiles removeObject:@"DefaultNote.txt"];
			files = mFiles.copy;
		}
		NSString *randomFile = files.count ? [path stringByAppendingPathComponent:files[arc4random_uniform(files.count)]] : nil;
		if (isImage) {
			UIImage *image = nil;
			if (randomFile) {
				image = [UIImage imageWithContentsOfFile:randomFile];
			}
			dispatch_async(dispatch_get_main_queue(), ^{
				__kindof UIImageView *imageView = [(MGImageContainerView *)imageContainer imageView];
				imageView.image = image;
				[imageView setNeedsDisplay];
			});
		}
		else {
			NSString *text = nil;
			if (files.count) {
				__unused NSStringEncoding encoding;
				text = [NSString
					stringWithContentsOfFile:randomFile
					usedEncoding:&encoding
					error:nil
				];
			}
			dispatch_async(dispatch_get_main_queue(), ^{
				[(MGTextContainerView *)imageContainer textLabel].text = text ?: @"Could not load note";
				if (!text) {
					[(MGTextContainerView *)imageContainer textLabel].font = [UIFont boldSystemFontOfSize:[(MGTextContainerView *)imageContainer textLabel].font.pointSize];
				}
			});
		}
	};
	pullMemeFrameHandler = ^(MGGooseView *sender, MGGooseFrameState state){
		if (state == MGGooseDidFinishDrawing) {
			CGPoint center = imageContainer.center;
			center.x += sender.positionChange.x;
			imageContainer.center = center;
		}
	};
	gotoMemeFrameHandler = ^(MGGooseView *sender, MGGooseFrameState state){
		if (state == MGGooseDidFinishDrawing) {
			if ((getMemeFromTheLeft) ?
				(sender.frame.origin.x <= -15.0) :
				(sender.frame.origin.x >= (gooseWindow.frame.size.width - sender.frame.size.width + 26.0)))
			{
				[sender removeFrameHandlerAtIndex:frameHandlerIndex];
				frameHandlerIndex = [sender addFrameHandler:pullMemeFrameHandler];
				CGPoint point = CGPointMake(-(imageContainer.frame.size.width/2.0), sender.center.y);
				CGFloat min = (imageContainer.frame.size.height / 2.0);
				CGFloat max = (gooseWindow.frame.size.height - min);
				point.y += (((CGFloat)arc4random_uniform(100) / 10.0) - 7.5);
				if (point.y < min) point.y = min;
				else if (point.y > max) point.y = max;
				if (!getMemeFromTheLeft) point.x += (imageContainer.frame.size.width + gooseWindow.frame.size.width);
				imageContainer.center = point;
				imageContainer.hidden = NO;
				dispatch_async(
					dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
					loadMeme
				);
				[sender walkForDuration:(3.0 + ((NSTimeInterval)arc4random_uniform(15) / 10.0)) speed:-2.0 completionHandler:finishMemeAnimation];
			}
		}
	};
	turnToMemeHandler = ^(MGGooseView *sender){
		frameHandlerIndex = [sender addFrameHandler:gotoMemeFrameHandler];
		sender.stopsAtEdge = NO;
		[sender walkForDuration:-1 speed:4.8 completionHandler:nil];
	};
	findMeme = ^(MGGooseView *sender){
		[sender setFacingTo:(!!getMemeFromTheLeft * 180.0) animationCompletion:turnToMemeHandler];
	};
	animation2Handler = ^(MGGooseView *sender){
		dispatch_after(
			dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * ((double)arc4random_uniform(50) / 10.0)),
			dispatch_get_main_queue(),
			^{
				uint8_t randomValue = arc4random_uniform(50);
				[containers compact];
				if ((containers.count >= 5) && (randomValue >= 40)) randomValue += 10;
				Class cls = nil;
				if ([(((NSNumber *)PrefValue(@"BringImages")) ?: @YES) boolValue] &&
					(randomValue <= 44) && (randomValue >= 40))
				{
					cls = [MGImageContainerView class];
				}
				else if ([(((NSNumber *)PrefValue(@"BringNotes")) ?: @NO) boolValue] &&
					(randomValue <= 49) && (randomValue >= 45))
				{
					cls = [MGTextContainerView class];
				}
				else {
					walkHandler(sender);
					return;
				}
				imageContainer = [[cls alloc] initWithFrame:CGRectMake(0,0,125,125)];
				[containers addPointer:(__bridge void *)imageContainer];
				imageContainer.transform = transform;
				imageContainer.hidden = YES;
				[containers compact];
				[gooseWindow.rootViewController.view addSubview:imageContainer];
				imageContainer.layer.zPosition = containers.count;
				getMemeFromTheLeft = arc4random_uniform(2);
				findMeme(sender);
			}
		);
	};
	walkHandler = ^(MGGooseView *sender){
		CGRect frame;
		CGFloat degrees = (CGFloat)arc4random_uniform(360);
		do {
			// Check if 
			frame = sender.frame;
			degrees += 10.0;
			frame.origin.x += cos(DEG_TO_RAD(degrees)) * defaultSpeed * 5.0;
			frame.origin.y += sin(DEG_TO_RAD(degrees)) * defaultSpeed * 5.0;
		} while ([sender isFrameAtEdge:frame]);
		[sender setFacingTo:degrees animationCompletion:animationHandler];
	};
	turnToUserAnimation = ^(MGGooseView *sender){
		CGRect bounds = viewController.view.bounds;
		CGFloat to = 45.0;
		if (sender.center.x > (bounds.size.width/2)) to = 180-to;
		[sender setFacingTo:to animationCompletion:animation2Handler];
	};
	animationHandler = ^(MGGooseView *sender){
		[sender
			walkForDuration:(NSTimeInterval)(arc4random_uniform(3)+1)
			speed:defaultSpeed
			completionHandler:turnToUserAnimation
		];
	};
	shouldRenderFrameBlock = ^BOOL(MGGooseView *sender){
		return !(
			[(SpringBoard *)UIApplication.sharedApplication isLocked] ||
			![(PrefValue(@"Enabled") ?: @YES) boolValue]
		);
	};
	containers = [NSPointerArray weakObjectsPointerArray];
	NSMutableArray *mHonks = [NSMutableArray new];
	const NSInteger gooseCount = 1;
	for (NSInteger i=0; i<gooseCount; i++) {
		CGRect frame = CGRectMake(0, 0, 0, 0);
		MGGooseView *honk = [[MGGooseView alloc] initWithFrame:frame];
		honk.shouldRenderFrameBlock = shouldRenderFrameBlock;
		frame.size = [honk sizeThatFits:frame.size];
		frame.origin = CGPointMake(
			arc4random_uniform(gooseWindow.frame.size.width - frame.size.width),
			arc4random_uniform(gooseWindow.frame.size.height - frame.size.height)
		);
		honk.frame = frame;
		[gooseWindow.rootViewController.view addSubview:honk];
		honk.layer.zPosition = 100;
		[mHonks addObject:honk];
		honk.facingTo = 0.0;
		animationHandler(honk);
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