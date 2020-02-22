#include "PXJoeTheGooseMod.h"

@implementation PXJoeTheGooseMod

- (instancetype)initWithGoose:(MGGooseView *)goose bundle:(NSBundle *)bundle {
	if ((self = [super init])) {
		nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(
			14.0,
			goose.frame.size.height / 1.5,
			goose.frame.size.width - 35.0,
			goose.frame.size.height / 5.0
		)];
		nameLabel.numberOfLines = 1;
		nameLabel.adjustsFontSizeToFitWidth = YES;
		nameLabel.textAlignment = NSTextAlignmentCenter;
		nameLabel.textColor = [UIColor blackColor];
		nameLabel.minimumScaleFactor = 0.1;
		nameLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
		[goose addSubview:nameLabel];
		[self preferenceWithKey:@"Name" didChangeToValue:nil];
	}
	return self;
}

- (void)setEnabled:(BOOL)enabled {
	nameLabel.hidden = !enabled;
	_enabled = enabled;
}

- (void)preferenceWithKey:(NSString *)key didChangeToValue:(id)value {
	if (!value) value = PrefValue(key);
	if (![key isEqualToString:@"Name"] || ![value isKindOfClass:[NSString class]]) return;
	nameLabel.text = ((NSString *)value).length ? value : @"Joe";
}

@end
