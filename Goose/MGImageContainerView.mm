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
		_failureLabel.text = @"Could not\nload meme";
		_failureLabel.font = [UIFont boldSystemFontOfSize:_failureLabel.font.pointSize];
		_failureLabel.textColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		_failureLabel.numberOfLines = 0;
		_failureLabel.textAlignment = NSTextAlignmentCenter;
		_imageView.layer.masksToBounds = YES;
		[self.contentView addSubview:_imageView];
		[self.contentView addSubview:_failureLabel];
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	_imageView.layer.cornerRadius = 0.1 * min(_imageView.frame.size.width, _imageView.frame.size.height);
	_imageView.frame = CGRectMake(0.0, 0.0, self.contentView.frame.size.width, self.contentView.frame.size.height);
	CGSize bestLabelSize = [_failureLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
	bestLabelSize.height *= 2;
	CGRect labelRect = CGRectMake(
		0.0,
		((self.contentView.frame.size.height/2.0) - (bestLabelSize.height/2.0)),
		self.contentView.frame.size.width,
		bestLabelSize.height
	);
	_failureLabel.frame = labelRect;
}

@end