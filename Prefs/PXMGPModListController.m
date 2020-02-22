#import "PXMGPModListController.h"
#import "PXMGPModDetailsController.h"
#import <Preferences/PSSpecifier.h>

@implementation PXMGPModListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSMutableArray *mutableSpecifiers = [NSMutableArray new];
		NSString *modRoot = @"/Library/MobileGoose/Mods";
		NSError *error = nil;
		NSArray *modNames = [NSFileManager.defaultManager
			contentsOfDirectoryAtPath:modRoot
			error:&error
		];
		PSSpecifier *specifier;
		if (!error && modNames.count) {
			specifier = [PSSpecifier
				preferenceSpecifierNamed:@"Installed Mods"
				target:nil
				set:nil
				get:nil
				detail:nil
				cell:PSGroupCell
				edit:nil
			];
			[mutableSpecifiers addObject:specifier];
			for (NSString *modName in modNames) {
				@autoreleasepool {
					NSString *fullModPath = [modRoot stringByAppendingPathComponent:modName];
					NSBundle *bundle = [NSBundle bundleWithPath:fullModPath];
					specifier = [PSSpecifier
						preferenceSpecifierNamed:(
							(bundle.localizedInfoDictionary ?: bundle.infoDictionary)[@"CFBundleDisplayName"] ?:
							modName.stringByDeletingPathExtension
						)
						target:self
						set:nil
						get:nil
						detail:(bundle ? [PXMGPModDetailsController class] : nil)
						cell:PSLinkCell
						edit:nil
					];
					NSLog(@"%@ %@", specifier.name, bundle.infoDictionary);
					[specifier setProperty:fullModPath forKey:@"modPath"];
					[mutableSpecifiers addObject:specifier];
				}
			}
		}
		else {
			specifier = [PSSpecifier
				preferenceSpecifierNamed:nil
				target:nil
				set:nil
				get:nil
				detail:nil
				cell:PSGroupCell
				edit:nil
			];
			[specifier setProperty:@"No MobileGoose mods seem to be installed." forKey:@"footerText"];
			[mutableSpecifiers addObject:specifier];
		}
		_specifiers = mutableSpecifiers.copy;
	}

	return _specifiers;
}

@end