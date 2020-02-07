#import "MGGooseView.h"

#define DEG_TO_RAD(degress) ((degress) * M_PI / 180.0)

@implementation MGGooseView

+ (void)rotatePath:(UIBezierPath *)path degree:(CGFloat)degree {
    CGRect bounds = CGPathGetBoundingBox(path.CGPath);
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
	[[UIColor colorWithWhite:0.25 alpha:0.25] setFill];
	@autoreleasepool {
		UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(10, 30, 30, 30)];
		[path fill];
	}

	// Feet
	[[UIColor orangeColor] setFill];
	@autoreleasepool {
		UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(20, 45, 8, 8)];
		[path fill];
	}
	
	// Body
	[[UIColor whiteColor] setFill];
	@autoreleasepool {
		CGRect oval1Rect = CGRectMake(15, 20, 20, 20);
		UIBezierPath *oval1 = [UIBezierPath bezierPathWithOvalInRect:oval1Rect];
		CGRect oval2Rect = CGRectMake(oval1Rect.origin.x, 55-oval1Rect.size.height, oval1Rect.size.width, oval1Rect.size.height);
		UIBezierPath *oval2 = [UIBezierPath bezierPathWithOvalInRect:oval2Rect];
		CGRect rectangleRect = CGRectMake(oval1Rect.origin.x, oval1Rect.origin.y+oval1Rect.size.height/2, oval1Rect.size.width, oval2Rect.origin.y-oval1Rect.origin.y);
		UIBezierPath *finalPath = [UIBezierPath bezierPathWithRect:rectangleRect];
		[finalPath appendPath:oval1];
		[finalPath appendPath:oval2];
		[self.class rotatePath:finalPath degree:facingToDegrees+90.0];
		[finalPath fill];
	}
	
	// Neck
	@autoreleasepool {
		// Create a rect without the correct position
		const CGFloat neckHeight = 10;
		CGRect rect = CGRectMake(0, 20, 15, neckHeight);
		
		// Calculate the correct position
		const CGFloat radius = 10.0;
		rect.origin.x += 17.5 + (radius * cos(facingToRadians));
		rect.origin.y += 4.8 + (radius * sin(facingToRadians));
		
		// Draw the neck
		UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
		rect = CGRectMake(
			rect.origin.x,
			rect.origin.y + rect.size.width - (rect.size.width / 2),
			rect.size.width,
			rect.size.width
		);
		[path appendPath:[UIBezierPath bezierPathWithOvalInRect:rect]];
		rect.origin.y -= rect.size.width;
		[path appendPath:[UIBezierPath bezierPathWithOvalInRect:rect]];
		[path fill];
	}
	
	// Face
	@autoreleasepool {
		// Create a rect without the correct position
		const CGFloat beakSize = 8.0;
		CGRect rect = CGRectMake(0, 20, beakSize, beakSize);
		
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
			rect.origin.x = 22.5 + (eyeRadius * cos(DEG_TO_RAD(facingToDegrees + offset)));
			rect.origin.y = 24.5 + (eyeRadius * sin(DEG_TO_RAD(facingToDegrees + offset)));
			path = [UIBezierPath bezierPathWithOvalInRect:rect];
			[path fill];
			offset = -offset;
		}
	}
}

- (void)timer:(id)unused {
	self.facingTo += 1.0;
	if (self.facingTo >= 360.0) {
		self.facingTo = 0.0;
	}
	if (!((int)self.facingTo % 30)) {
		CGRect rect = self.frame;
		rect.origin.x++;
		self.frame = rect;
	}
	[self setNeedsDisplay];
}

- (instancetype)init {
	if ((self = [super init])) {
		self.opaque = NO;
		self.backgroundColor = [UIColor clearColor];
		timer = [NSTimer scheduledTimerWithTimeInterval:(1.0/30.0) target:self selector:@selector(timer:) userInfo:nil repeats:YES];
	}
	return self;
}

@end
