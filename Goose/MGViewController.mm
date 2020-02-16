#import "MGViewController.h"
#import <substrate.h>
#import "MGContainerView.h"

@implementation MGViewController

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {
	return NO;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[UIApplication.sharedApplication performSelector:@selector(addActiveOrientationObserver:) withObject:self];
}

- (CGAffineTransform)transformForOrientation:(UIInterfaceOrientation)orientation {
    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft:
            _lastDegrees = -90; break;
        case UIInterfaceOrientationLandscapeRight:
            _lastDegrees = 90; break;
        case UIInterfaceOrientationPortraitUpsideDown:
            _lastDegrees = 180; break;
        case UIInterfaceOrientationPortrait:
        default: _lastDegrees = 0; break;
    }
	return CGAffineTransformMakeRotation(DEG_TO_RAD(_lastDegrees));
}

- (void)activeInterfaceOrientationDidChangeToOrientation:(long long)arg1 willAnimateWithDuration:(double)arg2 fromOrientation:(long long)arg3 {}
- (void)activeInterfaceOrientationWillChangeToOrientation:(long long)arg1 {}

@end