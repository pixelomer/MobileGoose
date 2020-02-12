#import <UIKit/UIKit.h>

@interface MGContainerView : UIView {
	UIVisualEffectView *_visualEffect;
}
@property (nonatomic, readonly, strong) UIView *contentView;
+ (UIBlurEffectStyle)blurStyle;
@end