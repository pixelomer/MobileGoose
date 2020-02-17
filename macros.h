#import <UIKit/UIKit.h>
#define DEG_TO_RAD(degress) ((degress) * M_PI / 180.0)
#define min(a,b) ((a<b)?a:b)
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

#import <Goose/MGGooseView.h>

@class SpringBoard;

@protocol MGMod
@optional
- (instancetype)initWithGoose:(MGGooseView *)goose;
- (instancetype)initWithGoose:(MGGooseView *)goose bundle:(NSBundle *)bundle;
- (void)handleFrameInState:(MGGooseFrameState)state;
- (void)springboardDidFinishLaunching:(SpringBoard *)application;
@end

CGAffineTransform MGGetTransform(void);