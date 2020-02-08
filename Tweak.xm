#import <UIKit/UIKit.h>
#import <Goose/MGGooseView.h>

static UIWindow *gooseWindow;
static void(^animationHandler)(void);

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
	%orig;
	gooseWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	gooseWindow.screen = [UIScreen mainScreen];
	gooseWindow.userInteractionEnabled = NO;
	gooseWindow.opaque = NO;
	gooseWindow.hidden = NO;
	gooseWindow.backgroundColor = [UIColor clearColor];
	gooseWindow.rootViewController = [UIViewController new];
	MGGooseView *gooseView = [MGGooseView new];
	CGRect frame = CGRectMake(100, 100, 0, 0);
	frame.size = [gooseView sizeThatFits:frame.size];
	gooseView.frame = frame;
	[gooseWindow.rootViewController.view addSubview:gooseView];
	gooseWindow.windowLevel = CGFLOAT_MAX - 1;
	[gooseWindow makeKeyAndVisible];
	[gooseWindow resignKeyWindow];
	animationHandler = ^{
		[gooseView setFacingTo:(CGFloat)arc4random_uniform(360) animationCompletion:animationHandler];
	};
	animationHandler();
}

%end