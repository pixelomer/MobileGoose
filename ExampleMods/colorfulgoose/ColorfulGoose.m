#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "MGGooseView.h"

__attribute__((constructor)) int ColorfulGooseConstructor() {
	Class _MGGooseView = objc_getClass("MGGooseView");
	[_MGGooseView addSharedFrameHandler:^(MGGooseView *sender, MGGooseFrameState state){
		if ((state == MGGooseWillDrawBody) || (state == MGGooseWillDrawNeck)) {
			NSNumber *hueObject = objc_getAssociatedObject(sender, @selector(ColorfulGoose)) ?: @0;
			CGFloat hue = [hueObject doubleValue];
			hue += 1.0;
			if (hue > (255*2)) hue = 0;
			UIColor *color = [UIColor
				colorWithHue:(floor(hue/2.0)/255.0)
				saturation:1.0
				brightness:1.0
				alpha:1.0
			];
			[color setFill];
			objc_setAssociatedObject(sender, @selector(ColorfulGoose), @(hue), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		}
	}];
	return 0;
}