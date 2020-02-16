#import <UIKit/UIKit.h>

@interface MGContainerView : UIView {
	UIVisualEffectView *_visualEffect;
}
@property (nonatomic, readonly, strong) UIView *contentView;
@property (nonatomic, assign) BOOL hideOnTap;
+ (UIBlurEffectStyle)blurStyle;
@end