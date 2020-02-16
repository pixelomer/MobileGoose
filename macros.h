#import <UIKit/UIKit.h>
#define DEG_TO_RAD(degress) ((degress) * M_PI / 180.0)
#define PrefValue(key) ([NSUserDefaults.standardUserDefaults \
	objectForKey:key \
	inDomain:@"com.pixelomer.mobilegoose" \
])

@interface NSUserDefaults(Private)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
@end

@interface UIView(Private)
- (UIViewController *)_viewControllerForAncestor;
@end

CGAffineTransform MGGetTransform(void);