#import "PXMGPRootListController.h"
#import <Preferences/PSSpecifier.h>
#import <substrate.h>
#import "Utilities.h"

@interface UIView(Private)
- (UIViewController *)_viewControllerForAncestor;
@end

static void (*MobileGoose$UILabel$setText$orig)(id,SEL,id) = nil;
static void MobileGoose$UILabel$setText$hook(UILabel *self, SEL _cmd, NSString *text) {
	if ([self._viewControllerForAncestor isKindOfClass:[PXMGPRootListController class]]) {
		if ([self.superview isKindOfClass:[UISlider class]]) {
			text = [text componentsSeparatedByString:@"."].firstObject;
		}
	}
	MobileGoose$UILabel$setText$orig(self, _cmd, text);
}

@implementation PXMGPRootListController

+ (void)load {
	if ((self == [PXMGPRootListController class]) && !MobileGoose$UILabel$setText$orig) {
		MSHookMessageEx(
			UILabel.class,
			@selector(setText:),
			(IMP)&MobileGoose$UILabel$setText$hook,
			(IMP*)&MobileGoose$UILabel$setText$orig
		);
	}
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (void)didRequestRespring:(PSSpecifier *)button {
	CFNotificationCenterPostNotification(
		CFNotificationCenterGetDarwinNotifyCenter(),
		CFSTR("com.pixelomer.mobilegoose/Exit"),
		NULL, NULL, YES
	);
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	[super setPreferenceValue:value specifier:specifier];
	NSNumber *requiresRespring = [specifier propertyForKey:@"requiresRespring"];
	if (requiresRespring.boolValue) {
		for (PSSpecifier *button in _specifiers) {
			SEL action = *(PXMGPGetSelectorIvar(button, "action"));
			if (action == @selector(didRequestRespring:)) {
				[button setProperty:@YES forKey:@"enabled"];
				[self reloadSpecifier:button];
			}
		}
	}
}

- (void)setPreferenceValue:(NSNumber *)value forDangerousSlider:(PSSpecifier *)specifier {
	[self setPreferenceValue:value specifier:specifier];
	NSNumber *recommendedMax = [specifier propertyForKey:@"recommendedMax"];
	NSNumber *didShowWarning = [specifier propertyForKey:@"__didShowWarning"];
	if (!didShowWarning.boolValue && (floor(value.doubleValue) > floor(recommendedMax.doubleValue))) {
		NSString *message = [NSString
			stringWithFormat:[specifier propertyForKey:@"warningMessage"],
			recommendedMax
		];
		if (@available(iOS 9.0, *)) {
			UIAlertController *alert = [UIAlertController
				alertControllerWithTitle:@"Warning"
				message:message
				preferredStyle:UIAlertControllerStyleAlert
			];
			[alert addAction:[UIAlertAction
				actionWithTitle:@"OK"
				style:UIAlertActionStyleDefault
				handler:nil
			]];
			[self presentViewController:alert animated:YES completion:nil];
		}
		else {
			UIAlertView *alert = [[UIAlertView alloc]
				initWithTitle:@"Warning"
				message:message
				delegate:nil
				cancelButtonTitle:@"OK"
				otherButtonTitles:nil
			];
			[alert show];
		}
		[specifier setProperty:@YES forKey:@"__didShowWarning"];
	}
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
