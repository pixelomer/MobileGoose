#include "PXMGPRootListController.h"
#import <Preferences/PSSpecifier.h>

@implementation PXMGPRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (void)setPreferenceValue:(NSNumber *)value forNotifyingSwitch:(PSSpecifier *)specifier {
	[self setPreferenceValue:value specifier:specifier];
	NSNotificationName notificationName;
	if ((value.boolValue && (notificationName = [specifier propertyForKey:@"trueNotification"])) ||
		(!value.boolValue && (notificationName = [specifier propertyForKey:@"falseNotification"])))
	{
		CFNotificationCenterPostNotification(
			CFNotificationCenterGetDarwinNotifyCenter(),
			(__bridge CFNotificationName)notificationName,
			NULL, NULL, YES
		);
	}
	if ((notificationName = [specifier propertyForKey:@"anyNotification"])) {
		[NSUserDefaults.standardUserDefaults synchronize];
		CFNotificationCenterPostNotification(
			CFNotificationCenterGetDarwinNotifyCenter(),
			(__bridge CFNotificationName)notificationName,
			NULL, NULL, YES
		);
	}
}

- (void)URLButtonPerformedAction:(PSSpecifier*)specifier {
	NSString *URLString = [specifier propertyForKey:@"url"];
	NSURL *URL;
	if (URLString && (URL = [NSURL URLWithString:URLString])) {
		[UIApplication.sharedApplication openURL:URL];
	}
}

@end
