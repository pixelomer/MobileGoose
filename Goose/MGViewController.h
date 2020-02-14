#import <UIKit/UIKit.h>

@protocol SBUIActiveOrientationObserver <NSObject>
- (void)activeInterfaceOrientationDidChangeToOrientation:(long long)arg1 willAnimateWithDuration:(double)arg2 fromOrientation:(long long)arg3;
- (void)activeInterfaceOrientationWillChangeToOrientation:(long long)arg1;
@end

@interface MGViewController : UIViewController<SBUIActiveOrientationObserver>
@property (nonatomic, assign) CGFloat lastDegrees;
- (UIInterfaceOrientationMask)supportedInterfaceOrientations;
- (void)activeInterfaceOrientationDidChangeToOrientation:(long long)arg1 willAnimateWithDuration:(double)arg2 fromOrientation:(long long)arg3;
- (void)activeInterfaceOrientationWillChangeToOrientation:(long long)arg1;
- (CGAffineTransform)transformForOrientation:(UIInterfaceOrientation)orientation;
@end