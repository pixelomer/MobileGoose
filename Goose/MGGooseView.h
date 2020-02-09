#import <UIKit/UIKit.h>

@interface MGGooseView : UIView {
	NSTimer *_timer;
	NSMutableArray<UIView *> *_mud;
	CGFloat _foot1Y;
	CGFloat _foot2Y;
	NSInteger _walkingState;
	CGFloat _targetFacingTo;
	NSInteger _remainingFramesUntilCompletion;
	void(^_walkCompletion)(MGGooseView *);
	void(^_animationCompletion)(MGGooseView *);
	CGFloat _walkMultiplier;
}
@property (nonatomic, strong) void(^frameHandler)(void);
@property (nonatomic, assign) CGFloat facingTo;
- (void)walkForDuration:(NSTimeInterval)duration
	speed:(CGFloat)speed
	completionHandler:(void(^)(MGGooseView *))completion;
- (void)setFacingTo:(CGFloat)degress
	animationCompletion:(void(^)(MGGooseView *))completion;
@end