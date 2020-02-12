#import <UIKit/UIKit.h>
#import <Goose/MGGooseView.h>
#import <Goose/MGImageContainerView.h>

static UIWindow *gooseWindow;
static void(^animationHandler)(MGGooseView *);
static void(^animation2Handler)(MGGooseView *);
static void(^showMeme)(MGGooseView *);
static void(^walkHandler)(MGGooseView *);
static void(^findMeme)(MGGooseView *);
static void(^gotoMemeFrameHandler)(MGGooseView *);
static void(^turnToMemeHandler)(MGGooseView *);
static void(^pullMemeFrameHandler)(MGGooseView *);
static void(^finishMemeAnimation)(MGGooseView *);
static void(^turnToUserAnimation)(MGGooseView *);
static void(^loadMeme)(void);
static MGImageContainerView *imageContainer;
static NSInteger frameHandlerIndex;
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
	imageContainer = [[MGImageContainerView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
	imageContainer.hidden = YES;
	[gooseWindow.rootViewController.view addSubview:imageContainer];
	[gooseWindow makeKeyAndVisible];
	[gooseWindow resignKeyWindow];
	finishMemeAnimation = ^(MGGooseView *sender){
		[sender removeFrameHandlerAtIndex:frameHandlerIndex];
		sender.stopsAtEdge = YES;
		turnToUserAnimation(sender);
	};
	loadMeme = ^{
		NSString *path = @"/Library/Application Support/MobileGoose/Memes";
		NSArray *files = [NSFileManager.defaultManager contentsOfDirectoryAtPath:path error:nil];
		UIImage *image = nil;
		if (files.count) {
			NSString *fullImagePath = [path stringByAppendingPathComponent:files[arc4random_uniform(files.count)]];
			image = [UIImage imageWithContentsOfFile:fullImagePath];
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			imageContainer.imageView.image = image;
			[imageContainer.imageView setNeedsDisplay];
		});
	};
	pullMemeFrameHandler = ^(MGGooseView *sender){
		CGPoint center = imageContainer.center;
		center.x += sender.positionChange.x;
		imageContainer.center = center;
	};
	gotoMemeFrameHandler = ^(MGGooseView *sender){
		if (sender.frame.origin.x <= -15.0) {
			[sender removeFrameHandlerAtIndex:frameHandlerIndex];
			frameHandlerIndex = [sender addFrameHandler:pullMemeFrameHandler];
			imageContainer.center = CGPointMake(-(imageContainer.frame.size.width/2.0), sender.center.y);
			imageContainer.hidden = NO;
			dispatch_async(
				dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
				loadMeme
			);
			[sender walkForDuration:3.0 speed:-2.0 completionHandler:finishMemeAnimation];
		}
	};
	turnToMemeHandler = ^(MGGooseView *sender){
		frameHandlerIndex = [sender addFrameHandler:gotoMemeFrameHandler];
		sender.stopsAtEdge = NO;
		[sender walkForDuration:-1 speed:4.8 completionHandler:nil];
	};
	findMeme = ^(MGGooseView *sender){
		[sender setFacingTo:180.0 animationCompletion:turnToMemeHandler];
	};
	animation2Handler = ^(MGGooseView *sender){
		dispatch_after(
			dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * ((double)arc4random_uniform(50) / 10.0)),
			dispatch_get_main_queue(),
			^{
				uint8_t randomValue = arc4random_uniform(3);
				if (randomValue == 1) findMeme(sender);
				else walkHandler(sender);
			}
		);
	};
	walkHandler = ^(MGGooseView *sender){
		[sender setFacingTo:(CGFloat)arc4random_uniform(360) animationCompletion:animationHandler];
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
			speed:2.6
			completionHandler:turnToUserAnimation];
	};
	NSMutableArray *mHonks = [NSMutableArray new];
	const NSInteger gooseCount = 1;
	for (NSInteger i=0; i<gooseCount; i++) {
		CGRect frame = CGRectMake(0, 0, 0, 0);
		MGGooseView *honk = [[MGGooseView alloc] initWithFrame:frame];
		frame.size = [honk sizeThatFits:frame.size];
		frame.origin = CGPointMake(
			arc4random_uniform(gooseWindow.rootViewController.view.frame.size.width - frame.size.width),
			arc4random_uniform(gooseWindow.rootViewController.view.frame.size.height - frame.size.height)
		);
		honk.frame = frame;
		[gooseWindow.rootViewController.view addSubview:honk];
		[mHonks addObject:honk];
		honk.facingTo = 0.0;
		animationHandler(honk);
	}
	honks = mHonks.copy;
	mHonks = nil;
}

%end