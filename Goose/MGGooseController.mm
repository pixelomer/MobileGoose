#import "MGGooseController.h"
#import "MGGooseView.h"
#import "MGTextContainerView.h"
#import "MGImageContainerView.h"
#import "MGViewController.h"
#import "MGGooseController.h"
#import "NSPointerArray+FixedCompact.h"

#pragma GCC diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"

@implementation MGGooseController

static const CGFloat defaultSpeed = 2.6;
static NSPointerArray *sharedContainers;

+ (void)load {
	if (self == [MGGooseController class]) {
		sharedContainers = [NSPointerArray weakObjectsPointerArray];
	}
}

- (void)loadMeme {
	BOOL isImage = [imageContainer isKindOfClass:[MGImageContainerView class]];
	NSString *path = [NSString
		stringWithFormat:@"/Library/MobileGoose/%@",
		isImage ? @"Memes" : @"Notes"
	];
	NSArray *files = [NSFileManager.defaultManager contentsOfDirectoryAtPath:path error:nil];
	if ([(((NSNumber *)PrefValue(@"DisableDefaultGifts")) ?: @NO) boolValue]) {
		NSMutableArray<NSString *> *mFiles = files.mutableCopy;
		for (NSInteger i=mFiles.count-1; i>=0; i--) {
			if ([mFiles[i] hasPrefix:@"Default"]) [mFiles removeObjectAtIndex:i];
		}
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
}

- (void)crazyModeCompletionTurnCompletion {
	[_gooseView walkForDuration:-1 speed:defaultSpeed completionHandler:nil];
	frameHandlerIndex = [_gooseView addFrameHandlerWithTarget:self action:@selector(getBackToNormalFrameHandlerForSender:state:)];
}

- (void)memeAnimationCompletion {
	[_gooseView removeFrameHandlerAtIndex:frameHandlerIndex];
	_gooseView.stopsAtEdge = YES;
	imageContainer.hideOnTap = YES;
	imageContainer = nil;
	[self turnToUserAnimation];
}

- (void)crazyModeCompletion {
	[_gooseView removeFrameHandlerAtIndex:frameHandlerIndex];
	if (![_gooseView isFrameAtEdge:_gooseView.frame]) {
		_gooseView.stopsAtEdge = YES;
		[self turnToUserAnimation];
	}
	else {
		[_gooseView setFacingTo:45.0 animationCompletion:^(id sender){
			[self crazyModeCompletionTurnCompletion];
		}];
	}
}

- (void)handleCrazyModeFrameForSender:(MGGooseView *)sender state:(MGGooseFrameState)state {
	if (state == MGGooseDidFinishDrawing) {
		sender.facingTo += ((CGFloat)arc4random_uniform(150) / 10.0) - 7.5;
	}
}

- (void)handleCrazyModePreparationFrameForSender:(MGGooseView *)sender state:(MGGooseFrameState)state {
	if (state == MGGooseDidFinishDrawing) {
		if (sender.positionChange.x <= -10) {
			[sender removeFrameHandlerAtIndex:frameHandlerIndex];
			[sender
				walkForDuration:((CGFloat)arc4random_uniform(30) / 10.0)+6.0
				speed:defaultSpeed*3.0
				completionHandler:^(MGGooseView *sender){ [self crazyModeCompletion]; }
			];
			frameHandlerIndex = [sender addFrameHandlerWithTarget:self action:@selector(handleCrazyModeFrameForSender:state:)];
		}
	}
}

- (void)prepareForGoingCrazy {
	_gooseView.stopsAtEdge = NO;
	[_gooseView walkForDuration:-1.0 speed:defaultSpeed completionHandler:nil];
	frameHandlerIndex = [_gooseView
		addFrameHandlerWithTarget:self
		action:@selector(handleCrazyModePreparationFrameForSender:state:)
	];
}

- (void)pullMemeFrameForSender:(MGGooseView *)sender state:(MGGooseFrameState)state {
	if (state == MGGooseDidFinishDrawing) {
		CGPoint center = imageContainer.center;
		center.x += sender.positionChange.x;
		imageContainer.center = center;
	}
}

- (void)continueWithRandomAnimation {
	uint8_t randomValue = arc4random_uniform(50);
	[containers MGCompact];
	if ((containers.count >= @(floor(((NSNumber *)(PrefValue(@"MaxGiftCount") ?: @5)).doubleValue)).integerValue) && (randomValue >= 40)) randomValue += 10;
	Class cls = nil;
	if ([(((NSNumber *)PrefValue(@"BringImages")) ?: @YES) boolValue] &&
		(randomValue <= 44) && (randomValue >= 40))
	{
		// 10% chance
		cls = [MGImageContainerView class];
	}
	else if ((randomValue >= 30) && (randomValue < 33)) {
		// 6% chance
		[_gooseView setFacingTo:0.0 animationCompletion:^(id sender){
			[self prepareForGoingCrazy];
		}];
		return;
	}
	else if ([(((NSNumber *)PrefValue(@"BringNotes")) ?: @NO) boolValue] &&
		(randomValue <= 49) && (randomValue >= 45))
	{
		// 10% chance
		cls = [MGTextContainerView class];
	}
	else {
		[self turnToRandomAngle];
		return;
	}
	imageContainer = [[cls alloc] initWithFrame:CGRectMake(0,0,125,125)];
	[containers addPointer:(__bridge void *)imageContainer];
	imageContainer.transform = MGGetTransform();
	imageContainer.hidden = YES;
	[containers MGCompact];
	[_gooseView._viewControllerForAncestor.view addSubview:imageContainer];
	imageContainer.layer.zPosition = containers.count;
	getMemeFromTheLeft = arc4random_uniform(2);
	[_gooseView setFacingTo:(!!getMemeFromTheLeft * 180.0) animationCompletion:^(id sender){
		[self turnToMemeAnimation];
	}];
}

- (void)gotoMemeFrameHandlerForSender:(MGGooseView *)sender state:(MGGooseFrameState)state {
	if (state == MGGooseDidFinishDrawing) {
		if ((getMemeFromTheLeft) ?
			(sender.frame.origin.x <= -15.0) :
			(sender.frame.origin.x >= (_gooseView._viewControllerForAncestor.view.frame.size.width - sender.frame.size.width + 26.0)))
		{
			[sender removeFrameHandlerAtIndex:frameHandlerIndex];
			frameHandlerIndex = [sender addFrameHandlerWithTarget:self action:@selector(pullMemeFrameForSender:state:)];
			CGPoint point = CGPointMake(-(imageContainer.frame.size.width/2.0), sender.center.y);
			CGFloat min = (imageContainer.frame.size.height / 2.0);
			CGFloat max = (sender._viewControllerForAncestor.view.frame.size.height - min);
			point.y += (((CGFloat)arc4random_uniform(100) / 10.0) - 7.5);
			if (point.y < min) point.y = min;
			else if (point.y > max) point.y = max;
			if (!getMemeFromTheLeft) point.x += (imageContainer.frame.size.width + sender._viewControllerForAncestor.view.frame.size.width);
			imageContainer.center = point;
			imageContainer.hidden = NO;
			dispatch_async(
				dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
				^{ [self loadMeme]; }
			);
			[sender walkForDuration:(2.25 + ((NSTimeInterval)arc4random_uniform(15) / 10.0)) speed:-2.0 completionHandler:^(id sender){
				[self memeAnimationCompletion];
			}];
		}
	}
}

- (void)turnToMemeAnimation {
	frameHandlerIndex = [_gooseView addFrameHandlerWithTarget:self action:@selector(gotoMemeFrameHandlerForSender:state:)];
	_gooseView.stopsAtEdge = NO;
	[_gooseView walkForDuration:-1 speed:4.8 completionHandler:nil];
}

- (void)turnToUserAnimation {
	CGRect bounds = _gooseView._viewControllerForAncestor.view.bounds;
	CGFloat to = 45.0;
	if (_gooseView.center.x > (bounds.size.width/2)) to = 180-to;
	[_gooseView setFacingTo:to animationCompletion:^(id sender){
		dispatch_after(
			dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * ((double)arc4random_uniform(50) / 10.0)),
			dispatch_get_main_queue(),
			^{ [self continueWithRandomAnimation]; }
		);
	}];
}

- (void)turnToRandomAngle {
	CGRect frame;
	CGFloat degrees = (CGFloat)arc4random_uniform(360);
	do {
		// Check if 
		frame = _gooseView.frame;
		degrees += 10.0;
		frame.origin.x += cos(DEG_TO_RAD(degrees)) * defaultSpeed * 5.0;
		frame.origin.y += sin(DEG_TO_RAD(degrees)) * defaultSpeed * 5.0;
	} while ([_gooseView isFrameAtEdge:frame]);
	[_gooseView
		setFacingTo:degrees
		animationCompletion:^(id sender){ [self defaultWalkAnimation]; }
	];
}

- (void)defaultWalkAnimation {
	[_gooseView
		walkForDuration:(NSTimeInterval)(arc4random_uniform(3)+1)
		speed:defaultSpeed
		completionHandler:^(id sender){ [self turnToUserAnimation]; }
	];
}

- (void)setUseSharedContainerArray:(BOOL)newValue {
	if (!!newValue != !!_useSharedContainerArray) {
		if (newValue) containers = sharedContainers;
		else containers = [NSPointerArray weakObjectsPointerArray];
	}
	_useSharedContainerArray = newValue;
}

- (instancetype)initWithGoose:(MGGooseView *)goose {
	if ((self = [super init])) {
		_gooseView = goose;
		self.useSharedContainerArray = YES;
	}
	return self;
}

- (void)startLooping {
	[self defaultWalkAnimation];
}

- (void)getBackToNormalFrameHandlerForSender:(MGGooseView *)sender state:(MGGooseFrameState)state {
	if (state == MGGooseDidFinishDrawing) {
		if (![sender isFrameAtEdge:sender.frame]) {
			sender.stopsAtEdge = YES;
			[sender stopWalking];
			[sender removeFrameHandlerAtIndex:frameHandlerIndex];
			[self turnToUserAnimation];
		}
	}
}

@end

#pragma GCC diagnostic pop