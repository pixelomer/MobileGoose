#import <UIKit/UIKit.h>
#import "MGContainerView.h"

@interface MGImageContainerView : MGContainerView
@property (nonatomic, strong, readonly) UILabel *failureLabel;
@property (nonatomic, strong, readonly) UIImageView *imageView;
@end