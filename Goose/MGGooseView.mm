#import "MGGooseView.h"

#define DEG_TO_RAD(degress) ((degress) * M_PI / 180.0)
#define FPS 30.0

@implementation MGGooseView

static UIColor *shadowColor;

+ (void)initialize {
	if (self == [MGGooseView class]) {
		shadowColor = [UIColor colorWithWhite:0.25 alpha:0.25];
	}
}

+ (void)rotatePath:(UIBezierPath *)path degree:(CGFloat)degree bounds:(CGRect)bounds {
    CGPoint center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    
    CGFloat radians = (degree / 180.0f * M_PI);
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, center.x, center.y);
    transform = CGAffineTransformRotate(transform, radians);
    transform = CGAffineTransformTranslate(transform, -center.x, -center.y);
    [path applyTransform:transform];
}

- (CGSize)sizeThatFits:(CGSize)size {
	return CGSizeMake(80, 80);
}

- (void)drawRect:(CGRect)rect {
	CGFloat facingToRadians = _facingTo * M_PI / 180.0;
	CGFloat facingToDegrees = _facingTo;

	// Shadow
	[shadowColor setFill];
	CGRect shadowBounds = CGRectMake(20, 30, 30, 30);
	@autoreleasepool {
		UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:shadowBounds];
		[path fill];
	}

	// Feet
	[[UIColor orangeColor] setFill];
	@autoreleasepool {
		CGFloat change = (_walkMultiplier / 2.6);
		switch (_walkingState) {
			case 0:
				if (_autoResetFeet) _foot1Y = _foot2Y = 36.0;
				break;
			case 1:
				_foot1Y += change;
				_foot2Y -= change;
				break;
			case 2:
				_foot1Y -= change;
				_foot2Y += change;
				break;
			case 3:
				_foot1Y += change;
				break;
		}
		const CGFloat footSize = 6.0;
		const CGFloat foot1X = 24.5;
		const CGFloat foot2X = 38.5;
		if (_walkMultiplier < 0.0) {
			change = _foot2Y;
			_foot2Y = _foot1Y;
			_foot1Y = change;
		}
		switch (_walkingState) {
			case 1:
			case 3:
				if (_foot1Y >= 50.0) {
					_walkingState = 2;
					_foot1Y = 50.0;
					_foot2Y = 36.0;
				}
				break;
			case 2:
				if (_foot1Y <= 36.0) {
					_walkingState = 1;
					_foot2Y = 50.0;
					_foot1Y = 36.0;
				}
				break;
		}
		if (_walkMultiplier < 0.0) {
			change = _foot2Y;
			_foot2Y = _foot1Y;
			_foot1Y = change;
		}
		UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(foot1X, _foot1Y, footSize, footSize)];
		[path appendPath:[UIBezierPath bezierPathWithOvalInRect:CGRectMake(foot2X, _foot2Y, footSize, footSize)]];
		[self.class rotatePath:path degree:facingToDegrees+90.0 bounds:shadowBounds];
		[path fill];
	}
	
	// Body
	[[UIColor whiteColor] setFill];
	@autoreleasepool {
		CGRect oval1Rect = CGRectMake(25, 20, 20, 20);
		UIBezierPath *oval1 = [UIBezierPath bezierPathWithOvalInRect:oval1Rect];
		CGRect oval2Rect = CGRectMake(oval1Rect.origin.x, 55-oval1Rect.size.height, oval1Rect.size.width, oval1Rect.size.height);
		UIBezierPath *oval2 = [UIBezierPath bezierPathWithOvalInRect:oval2Rect];
		CGRect rectangleRect = CGRectMake(oval1Rect.origin.x, oval1Rect.origin.y+oval1Rect.size.height/2, oval1Rect.size.width, oval2Rect.origin.y-oval1Rect.origin.y);
		UIBezierPath *finalPath = [UIBezierPath bezierPathWithRect:rectangleRect];
		[finalPath appendPath:oval1];
		[finalPath appendPath:oval2];
		[self.class rotatePath:finalPath degree:facingToDegrees+90.0 bounds:finalPath.bounds];
		[finalPath fill];
	}
	
	// Neck
	@autoreleasepool {
		// Create a rect without the correct position
		const CGFloat neckHeight = 10;
		CGRect rect = CGRectMake(10, 20, 15, neckHeight);
		
		// Calculate the correct position
		const CGFloat radius = 10.0;
		rect.origin.x += 17.5 + (radius * cos(facingToRadians));
		rect.origin.y += 4.8 + (radius * sin(facingToRadians));
		
		// Draw the neck
		UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
		rect = CGRectMake(
			rect.origin.x,
			rect.origin.y - (rect.size.width / 2),
			rect.size.width,
			rect.size.width
		);
		[path appendPath:[UIBezierPath bezierPathWithOvalInRect:rect]];
		rect.origin.y += rect.size.width;
		[path appendPath:[UIBezierPath bezierPathWithOvalInRect:rect]];
		[path fill];
	}
	
	// Face
	@autoreleasepool {
		// Create a rect without the correct position
		const CGFloat beakSize = 8.0;
		CGRect rect = CGRectMake(10, 20, beakSize, beakSize);
		
		// Calculate the correct position
		const CGFloat beakRadius = 15.0;
		rect.origin.x += 21.0 + (beakRadius * cos(facingToRadians));
		rect.origin.y += 4.5 + (beakRadius * sin(facingToRadians));
		
		[[UIColor orangeColor] setFill];
		UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
		[path fill];
		
		const CGFloat eyeSize = beakSize * 0.6;
		const CGFloat eyeRadius = beakRadius - 3.0;
		rect.size.height = rect.size.width = eyeSize;
		[[UIColor blackColor] setFill];
		for (int8_t i=0, offset=15; i<2; i+=1.0) {
			rect.origin.x = 32.5 + (eyeRadius * cos(DEG_TO_RAD(facingToDegrees + offset)));
			rect.origin.y = 24.5 + (eyeRadius * sin(DEG_TO_RAD(facingToDegrees + offset)));
			path = [UIBezierPath bezierPathWithOvalInRect:rect];
			[path fill];
			offset = -offset;
		}
	}
	if (_remainingFramesUntilCompletion == 0) _walkingState = 0;
	if (_remainingFramesUntilCompletion >= 0) _remainingFramesUntilCompletion--;
	for (NSUInteger i=0; i<_frameHandlers.count; i++) {
		void(^handler)(MGGooseView *) = (typeof(handler))[_frameHandlers pointerAtIndex:i];
		if (handler) handler(self);
	}
}

- (NSUInteger)addFrameHandler:(void(^)(MGGooseView *))handler {
	for (NSUInteger i=0; i<_frameHandlers.count; i++) {
		if (![_frameHandlers pointerAtIndex:i]) {
			[_frameHandlers replacePointerAtIndex:i withPointer:(__bridge void *)handler];
			return i;
		}
	}
	[_frameHandlers addPointer:(__bridge void *)handler];
	return _frameHandlers.count - 1;
}

- (void)removeFrameHandlerAtIndex:(NSUInteger)index {
	[_frameHandlers replacePointerAtIndex:index withPointer:NULL];
}

- (void)setFacingTo:(CGFloat)degrees animationCompletion:(void(^)(MGGooseView *))completion {
	_targetFacingTo = degrees;
	_animationCompletion = completion;
}

- (void)walkForDuration:(NSTimeInterval)duration speed:(CGFloat)multiplier completionHandler:(void(^)(MGGooseView *))completion {
	_remainingFramesUntilCompletion = duration * FPS;
	_walkCompletion = completion;
	_walkingState = (multiplier >= 0.0) ? 3 : 2;
	_walkMultiplier = multiplier;
}

- (void)timer:(id)unused {
	if (_targetFacingTo >= 0.0) {
		CGFloat change;
		if (_targetFacingTo > _facingTo) change = 1.0;
		else change = -1.0;
		CGFloat absoluteDifference = fabs(_facingTo - _targetFacingTo);
		if (absoluteDifference <= 0.01) {
			_facingTo = _targetFacingTo;
			_targetFacingTo = -1.0;
			if (_animationCompletion) {
				// Completion handler might set _animationCompletion itself.
				void(^completion)(MGGooseView *) = _animationCompletion;
				_animationCompletion = nil;
				completion(self);
			}
		}
		else {
			if (absoluteDifference <= 1.0) change *= absoluteDifference;
			else if (absoluteDifference <= 10.0);
			else change *= (absoluteDifference / 5.0);
			_facingTo += change;
		}
	}
	CGRect oldFrame = self.frame;
	if (_remainingFramesUntilCompletion != -1) {
		CGRect frame = self.frame;
		frame.origin.x += cos(DEG_TO_RAD(_facingTo)) * _walkMultiplier;
		frame.origin.y += sin(DEG_TO_RAD(_facingTo)) * _walkMultiplier;
		CGRect screenBounds = self._viewControllerForAncestor.view.bounds;
		if (_stopsAtEdge &&
			(((frame.origin.x + frame.size.width) >= (screenBounds.size.width - 1)) ||
			((frame.origin.y + frame.size.height) >= (screenBounds.size.height - 1)) ||
			(frame.origin.x <= 1) ||
			(frame.origin.y <= 1))
		) {
			_remainingFramesUntilCompletion = -1;
			_walkingState = 0;
		}
		else {
			#define test(a, b) if ((frame.origin. a + frame.size. b) < 0) { \
				frame.origin. a = self._viewControllerForAncestor.view.frame.size. b + self.frame.size. b; \
			} \
			else if ((frame.origin. a - frame.size. b) > self._viewControllerForAncestor.view.frame.size. b) { \
				frame.origin. a = -(self.frame.size. b); \
			}
			test(x, width);
			test(y, height);
			#undef test
			self.frame = frame;
		}
	}
	if ((_remainingFramesUntilCompletion == -1) && _walkCompletion) {
		void(^completion)(MGGooseView *) = _walkCompletion;
		_walkCompletion = nil;
		completion(self);
	}
	if (_facingTo >= 360.0) {
		_facingTo = 0.0;
	}
	_positionChange.x = self.frame.origin.x - oldFrame.origin.x;
	_positionChange.y = self.frame.origin.y - oldFrame.origin.y;
	[self setNeedsDisplay];
}

- (instancetype)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.opaque = NO;
		self.backgroundColor = [UIColor clearColor];
		_foot1Y = 36.0;
		_walkingState = 0;
		_facingTo = 45.0;
		_remainingFramesUntilCompletion = -1;
		_frameHandlers = [NSPointerArray strongObjectsPointerArray];
		_targetFacingTo = -1.0;
		_foot2Y = 36.0;
		_stopsAtEdge = YES;
		_timer = [NSTimer scheduledTimerWithTimeInterval:(1.0/FPS) target:self selector:@selector(timer:) userInfo:nil repeats:YES];
	}
	return self;
}

- (instancetype)init {
	return [self initWithFrame:CGRectZero];
}

@end
