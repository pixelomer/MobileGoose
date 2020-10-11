#import <Foundation/Foundation.h>
#import <substrate.h>
#import "Utilities.h"

extern "C" SEL *PXMGPGetSelectorIvar(id obj, const char *name) {
  return &(MSHookIvar<SEL>(obj, name));
}