#import <UIKit/UIKit.h>
#import <Goose/MGGooseView.h>

static UIWindow *gooseWindow;
static void(^animationHandler)(MGGooseView *);
static void(^animation2Handler)(MGGooseView *);
static void(^walkHandler)(MGGooseView *);
static NSArray *honks;
static UIViewController *viewController;

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
	%orig;
	gooseWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	gooseWindow.screen = [UIScreen mainScreen];
	gooseWindow.userInteractionEnabled = NO;
	gooseWindow.opaque = NO;
	gooseWindow.hidden = NO;
	gooseWindow.backgroundColor = [UIColor clearColor];
	gooseWindow.rootViewController = viewController = [UIViewController new];
	gooseWindow.windowLevel = CGFLOAT_MAX - 1;
	[gooseWindow makeKeyAndVisible];
	[gooseWindow resignKeyWindow];
	animation2Handler = ^(MGGooseView *sender){
		dispatch_after(
			dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * (arc4random_uniform(4)+1)),
			dispatch_get_main_queue(),
			^{ walkHandler(sender); }
		);
	};
	walkHandler = ^(MGGooseView *sender){
		[sender setFacingTo:(CGFloat)arc4random_uniform(360) animationCompletion:animationHandler];
	};
	animationHandler = ^(MGGooseView *sender){
		[sender walkForDuration:(NSTimeInterval)(arc4random_uniform(3)+1) speed:2.6 completionHandler:^(MGGooseView *sender){
			CGRect bounds = viewController.view.bounds;
			CGFloat to = 45.0;
			if (sender.center.x > (bounds.size.width/2)) to = 180-to;
			[sender setFacingTo:to animationCompletion:animation2Handler];
		}];
	};
	NSMutableArray *mHonks = [NSMutableArray new];
	const NSInteger gooseCount = 1;
	for (NSInteger i=0; i<gooseCount; i++) {
		CGRect frame = CGRectMake(100, 100, 0, 0);
		MGGooseView *honk = [[MGGooseView alloc] initWithFrame:frame];
		frame.size = [honk sizeThatFits:frame.size];
		honk.frame = frame;
		[gooseWindow.rootViewController.view addSubview:honk];
		[mHonks addObject:honk];
		animationHandler(honk);
	}
	honks = mHonks.copy;
	mHonks = nil;
}

%end