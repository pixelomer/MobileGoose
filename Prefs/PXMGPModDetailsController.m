#include "PXMGPModDetailsController.h"
#import <Preferences/PSSpecifier.h>
#import "Utilities.h"

@interface PSSpecifier(Private)
- (instancetype)initWithName:(NSString *)identifier target:(id)target set:(SEL)set get:(SEL)get detail:(Class)detail cell:(PSCellType)cellType edit:(Class)edit;
@end

@interface NSUserDefaults(Private)
- (void)setObject:(id)arg1 forKey:(id)arg2 inDomain:(id)arg3;
- (id)objectForKey:(id)arg1 inDomain:(id)arg2;
@end

@interface NSDistributedNotificationCenter : NSNotificationCenter
- (void)postNotificationName:(NSNotificationName)name
	object:(NSString *)object 
	userInfo:(NSDictionary *)userInfo 
	deliverImmediately:(BOOL)deliverImmediately;
@end

@implementation PXMGPModDetailsController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = self.specifier.name;
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSString *modPath = [self.specifier propertyForKey:@"modPath"];
		if (!modPath) return nil;
		_modBundle = [NSBundle bundleWithPath:modPath];
		if (!_modBundle) return nil;
		NSMutableArray *mutableSpecifiers = [NSMutableArray new];
		PSSpecifier *enabledSpecifier;
		SEL setter = @selector(setModPreferenceValue:specifier:);
		SEL getter = @selector(modPreferenceValueForSpecifier:);
		enabledSpecifier = [PSSpecifier
			preferenceSpecifierNamed:@"Enabled"
			target:self
			set:setter
			get:getter
			detail:nil
			cell:PSSwitchCell
			edit:nil
		];
		[enabledSpecifier setProperty:@"Enabled" forKey:@"key"];
		[enabledSpecifier setProperty:@YES forKey:@"default"];
		[mutableSpecifiers addObject:enabledSpecifier];
		NSArray *specifiersFromFile = [self
			loadSpecifiersFromPlistName:@"Root"
			target:self
			bundle:_modBundle
		];
		for (PSSpecifier *specifier in specifiersFromFile) {
			specifier.target = self;
			*(PXMGPGetSelectorIvar(specifier, "getter")) = getter;
			*(PXMGPGetSelectorIvar(specifier, "setter")) = setter;
			[mutableSpecifiers addObject:specifier];
		}
		_specifiers = mutableSpecifiers.copy;
	}
	return _specifiers;
}

- (void)setModPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	NSLog(@"%@ <= %@", specifier, value);
	NSString *key = [specifier propertyForKey:@"key"];
	NSString *bundleID = _modBundle.bundleIdentifier;
	[NSUserDefaults.standardUserDefaults setObject:value forKey:key inDomain:bundleID];
	[NSUserDefaults.standardUserDefaults synchronize];
	[(NSDistributedNotificationCenter *)[NSClassFromString(@"NSDistributedNotificationCenter") defaultCenter]
		postNotificationName:@"com.pixelomer.mobilegoose/ModPreferencesChanged"
		object:_modBundle.bundlePath
		userInfo:@{ @"key": key, @"newValue" : value }
		deliverImmediately:YES
	];
}

- (id)modPreferenceValueForSpecifier:(PSSpecifier *)specifier {
	NSString *key = [specifier propertyForKey:@"key"];
	NSString *bundleID = _modBundle.bundleIdentifier;
	id value = [NSUserDefaults.standardUserDefaults objectForKey:key inDomain:bundleID];
	NSLog(@"%@ => %@", specifier, value);
	return value ?: [specifier propertyForKey:@"default"];
}

@end