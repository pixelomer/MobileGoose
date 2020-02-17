#import <UIKit/UIKit.h>
#import "../MobileGoose.h"

@interface PXColorfulGooseMod : NSObject<MGMod> {
	CGFloat hue;
}
- (void)handleFrameInState:(MGGooseFrameState)state;
@end