#import "PXNameTagMod.h"

@implementation PXNameTagMod

- (instancetype)initWithGoose:(MGGooseView *)goose {
	if ((self = [super init])) {
		UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(
			14.0,
			goose.frame.size.height / 1.5,
			goose.frame.size.width - 35.0,
			goose.frame.size.height / 5.0
		)];
		nameLabel.numberOfLines = 1;
		nameLabel.adjustsFontSizeToFitWidth = YES;
		nameLabel.textAlignment = NSTextAlignmentCenter;
		nameLabel.minimumScaleFactor = 0.1;
		nameLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.75];
		nameLabel.text = @"Joe";
		[goose addSubview:nameLabel];
	}
	return self;
}

@end