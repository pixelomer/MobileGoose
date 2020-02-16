#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "MGGooseView.h"

static NSArray *colors;

__attribute__((constructor)) int ColorfulGooseConstructor() {
	@autoreleasepool {
		NSMutableArray *mColors = [NSMutableArray new];
		for (uint16_t i=0; i<256; i++) {
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
	Class _MGGooseView = objc_getClass("MGGooseView");
	[_MGGooseView addSharedFrameHandler:^(MGGooseView *sender, MGGooseFrameState state){
		if ((state == MGGooseWillDrawBody) || (state == MGGooseWillDrawNeck)) {
			NSNumber *hueObject = objc_getAssociatedObject(sender, @selector(ColorfulGoose)) ?: @0;
			CGFloat hue = [hueObject doubleValue];
			hue += 1.0;
			if (hue > (255*2)) hue = 0;
			UIColor *color = colors[(int)floor(hue/2.0)];
			[color setFill];
			objc_setAssociatedObject(sender, @selector(ColorfulGoose), @(hue), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		}
	}];
	return 0;
}