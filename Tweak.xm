#import <UIKit/UIKit.h>
#import <Goose/MGGooseView.h>

static UIWindow *gooseWindow;
static void(^animationHandler)(void);
static void(^animation2Handler)(void);
static void(^walkHandler)(void);
static MGGooseView *gooseView;
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
	gooseView = [MGGooseView new];
	CGRect frame = CGRectMake(100, 100, 0, 0);
	frame.size = [gooseView sizeThatFits:frame.size];
	gooseView.frame = frame;
	[gooseWindow.rootViewController.view addSubview:gooseView];
	gooseWindow.windowLevel = CGFLOAT_MAX - 1;
	[gooseWindow makeKeyAndVisible];
	[gooseWindow resignKeyWindow];
	animation2Handler = ^{
		dispatch_after(
			dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * (arc4random_uniform(4)+1)),
			dispatch_get_main_queue(),
			walkHandler
		);
	};
	walkHandler = ^{
		[gooseView setFacingTo:(CGFloat)arc4random_uniform(360) animationCompletion:animationHandler];
	};
	animationHandler = ^{
		[gooseView walkForDuration:(NSTimeInterval)(arc4random_uniform(3)+1) multiplier:2.6 completionHandler:^{
			CGRect bounds = viewController.view.bounds;
			CGFloat to = 45.0;
			if (gooseView.center.x > (bounds.size.width/2)) to = 180-to;
			[gooseView setFacingTo:to animationCompletion:animation2Handler];
		}];
	};
	animationHandler();
}

%end