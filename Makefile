INSTALL_TARGET_PROCESSES = SpringBoard
TARGET = iphone:11.2:8.0
ARCHS = arm64 arm64e armv7
export TARGET

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MobileGoose

MobileGoose_FRAMEWORKS = UIKit Foundation
MobileGoose_FILES = Tweak.xm $(wildcard */*.mm)
MobileGoose_CFLAGS = -fobjc-arc -I. -include macros.h -ferror-limit=0

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += Prefs
include $(THEOS_MAKE_PATH)/aggregate.mk
