#import <UIKit/UIKit.h>

@interface MGGooseView : UIView {
	NSTimer *_timer;
	CGFloat _foot1Y;
	CGFloat _foot2Y;
	NSInteger _walkingState;
	CGFloat _targetFacingTo;
	void(^_animationCompletion)(void);
}
@property (nonatomic, assign) CGFloat facingTo;
- (void)setFacingTo:(CGFloat)degress animationCompletion:(void(^)(void))completion;
@end