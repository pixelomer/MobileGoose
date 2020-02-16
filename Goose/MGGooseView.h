#import <UIKit/UIKit.h>

// ALL of the methods in this class MUST be called on the main thread.

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
typedef void(^MGGooseCommonBlock)(MGGooseView *);

// Do you think I'm using the wrong terms in variable names? If so,
// feel free to make a pull request that fixes it.

@interface MGGooseView : UIView {
	NSTimer *_timer;
	CGFloat _foot1Y;
	CGFloat _foot2Y;
	NSInteger _walkingState;
	CGFloat _targetFacingTo;
	NSInteger _remainingFramesUntilCompletion;
	MGGooseCommonBlock _walkCompletion;
	MGGooseCommonBlock _animationCompletion;
	CGFloat _walkMultiplier;
	NSMutableArray *_frameHandlers;
}
@property (nonatomic, strong) BOOL(^shouldRenderFrameBlock)(MGGooseView *);
@property (nonatomic, assign) CGFloat facingTo;
@property (nonatomic, assign) BOOL stopsAtEdge;
@property (nonatomic, assign, readonly) CGPoint positionChange;
@property (nonatomic, assign) BOOL autoResetFeet;
- (void)walkForDuration:(NSTimeInterval)duration
	speed:(CGFloat)speed
	completionHandler:(MGGooseCommonBlock)completion;
- (void)setFacingTo:(CGFloat)degress
	animationCompletion:(MGGooseCommonBlock)completion;
- (void)stopWalking;
- (NSUInteger)addFrameHandler:(MGGooseFrameHandler)handler;
- (NSUInteger)addFrameHandlerWithTarget:(id)target action:(SEL)action;
- (void)removeFrameHandlerAtIndex:(NSUInteger)index;
- (BOOL)isFrameAtEdge:(CGRect)frame;
+ (void)addSharedFrameHandler:(MGGooseFrameHandler)handler;
//+ (void)addSharedFrameHandlerWithTarget:(id)target action:(SEL)action;
@end