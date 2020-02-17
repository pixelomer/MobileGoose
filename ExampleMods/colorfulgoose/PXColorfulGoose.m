#import "PXColorfulGoose.h"

@implementation PXColorfulGoose

static NSArray<UIColor *> *colors;

+ (void)initialize {
	if ([PXColorfulGoose class] == self) {
		NSMutableArray *mColors = [NSMutableArray new];
		for (uint16_t i=0; i<=255; i++) {
			[mColors addObject:[UIColor
				colorWithHue:((CGFloat)i / (CGFloat)255.0)
				saturation:1.0
				brightness:1.0
				alpha:1.0
			]];
		}
		colors = mColors.copy;
		mColors = nil;
	}
}

// This method is called inside drawRect. [color setFill] will change the
// color for the neck and the body.
- (void)handleFrameInState:(MGGooseFrameState)state {
	if ((state == MGGooseWillDrawBody) || (state == MGGooseWillDrawNeck)) {
		hue += 1.0;
		if (hue > (255*2)) hue = 0.0;
		UIColor *color = colors[(int)floor(hue/2.0)];
		[color setFill];
	}
}

@end