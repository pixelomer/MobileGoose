#import <UIKit/UIKit.h>
#import <MobileGoose.h>

@interface PXColorfulGoose : NSObject<MGMod> {
	CGFloat hue;
}
- (void)handleFrameInState:(MGGooseFrameState)state;
@property (nonatomic, assign) BOOL enabled;
@end