#include "@@CLASSNAME@@.h"

@implementation @@CLASSNAME@@

- (instancetype)initWithGoose:(MGGooseView *)goose bundle:(NSBundle *)bundle {
	// TODO: Initialize mod
	if ((self = [super init])) {
		_goose = goose;
	}
	return self;
}

- (void)handleFrameInState:(MGGooseFrameState)state {
	// TODO: Handle frame
}

- (void)springboardDidFinishLaunching:(SpringBoard *)application {
	// TODO: Do necessary initialization after SpringBoard finishes launching
	//       Not required most of the time.
}

@end
