#import "MGImageView.h"
#import "MGImageContainerView.h"

@implementation MGImageView

- (void)setImage:(UIImage *)image {
	if ([self.superview.superview isKindOfClass:[MGImageContainerView class]]) {
		((MGImageContainerView *)self.superview.superview).failureLabel.hidden = !!image;
	}
	[super setImage:image];
}

@end