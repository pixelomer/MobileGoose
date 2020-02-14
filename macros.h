#import <UIKit/UIKit.h>
#define DEG_TO_RAD(degress) ((degress) * M_PI / 180.0)

@interface UIView(Private)
- (UIViewController *)_viewControllerForAncestor;
@end