#import "NSPointerArray+FixedCompact.h"

@implementation NSPointerArray(FixedCompact)

- (void)MGCompact {
	for (NSInteger i=self.count-1; i>=0; i--) {
		if ([self pointerAtIndex:i] == NULL) {
			[self removePointerAtIndex:i];
		}
	}
}

@end