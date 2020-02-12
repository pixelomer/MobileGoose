#import "MGImageContainerView.h"
#import "MGImageView.h"

@implementation MGImageContainerView

- (instancetype)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_imageView = [MGImageView new];
		if (!_imageView) return nil;
		_failureLabel = [UILabel new];
		if (!_failureLabel) return nil;
		_imageView.contentMode = UIViewContentModeScaleAspectFit;
		_failureLabel.text = @"fatal erorr";
		_failureLabel.textAlignment = NSTextAlignmentCenter;
		[self.contentView addSubview:_imageView];
		[self.contentView addSubview:_failureLabel];
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	_imageView.frame = CGRectMake(0.0, 0.0, self.contentView.frame.size.width, self.contentView.frame.size.height);
	CGSize bestLabelSize = [_failureLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
	CGRect labelRect = CGRectMake(
		0.0,
		((self.contentView.frame.size.height/2.0) - (bestLabelSize.height/2.0)),
		self.contentView.frame.size.width,
		bestLabelSize.height
	);
	_failureLabel.frame = labelRect;
}

@end