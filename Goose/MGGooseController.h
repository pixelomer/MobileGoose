#import <UIKit/UIKit.h>

@class MGGooseView;
@class MGContainerView;

@interface MGGooseController : NSObject {
	NSPointerArray *containers;
	NSInteger frameHandlerIndex;
	BOOL getMemeFromTheLeft;
	__kindof MGContainerView *imageContainer;
}
@property (nonatomic, strong, readonly) MGGooseView *gooseView;
- (instancetype)initWithGoose:(MGGooseView *)goose;
- (void)startLooping;
@end