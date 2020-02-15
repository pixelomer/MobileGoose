#import <UIKit/UIKit.h>

@class MGGooseView;

typedef NS_ENUM(NSInteger, MGGooseFrameState) {
	MGGooseWillStartDrawing = 0b10000000,
	MGGooseDidFinishDrawing = 0,
	#define e(name, val) MGGooseDidDraw##name = val, MGGooseWillDraw##name = (val | 0b10000000)
	e(Shadow, 1),
	e(Feet, 2),
	e(Body, 3),
	e(Neck, 4),
	e(Eyes, 5),
	e(Beak, 6)
	#undef e
};
typedef void(^MGGooseFrameHandler)(MGGooseView *, MGGooseFrameState);

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
- (NSUInteger)addFrameHandler:(MGGooseFrameHandler)handler;
- (void)removeFrameHandlerAtIndex:(NSUInteger)index;
@end