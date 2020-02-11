#import <UIKit/UIKit.h>

// Do you think I'm using the wrong terms in variable names? If so,
// feel free to make a pull request that fixes it.

@interface MGGooseView : UIView {
	NSTimer *_timer;
	CGFloat _foot1Y;
	CGFloat _foot2Y;
	NSInteger _walkingState;
	CGFloat _targetFacingTo;
	NSInteger _remainingFramesUntilCompletion;
	void(^_walkCompletion)(MGGooseView *);
	void(^_animationCompletion)(MGGooseView *);
	CGFloat _walkMultiplier;
	NSPointerArray *_frameHandlers;
}
@property (nonatomic, assign) CGFloat facingTo;
@property (nonatomic, assign) BOOL stopsAtEdge;
@property (nonatomic, assign, readonly) CGPoint positionChange;
@property (nonatomic, assign) BOOL autoResetFeet;
- (void)walkForDuration:(NSTimeInterval)duration
	speed:(CGFloat)speed
	completionHandler:(void(^)(MGGooseView *))completion;
- (void)setFacingTo:(CGFloat)degress
	animationCompletion:(void(^)(MGGooseView *))completion;
- (NSUInteger)addFrameHandler:(void(^)(MGGooseView *))handler;
- (void)removeFrameHandlerAtIndex:(NSUInteger)index;
@end