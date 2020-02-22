#import <UIKit/UIKit.h>
#import <MobileGoose.h>

#define PrefValue(key) ([NSUserDefaults.standardUserDefaults \
	objectForKey:key \
	inDomain:@"com.pixelomer.joethegoose" \
])

@interface NSUserDefaults(Private)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
@end

@interface PXJoeTheGooseMod : NSObject<MGMod> {
	UILabel *nameLabel;
}
@property (nonatomic, assign) BOOL enabled;
@end
