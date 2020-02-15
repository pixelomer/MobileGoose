#import <UIKit/UIKit.h>

@interface MGContainerView : UIView {
	UIVisualEffectView *_visualEffect;
	UITapGestureRecognizer *_gestureRecognizer;
}
@property (nonatomic, readonly, strong) UIView *contentView;
+ (UIBlurEffectStyle)blurStyle;
@end