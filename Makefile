INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MobileGoose

MobileGoose_FILES = Tweak.xm $(wildcard */*.mm)
MobileGoose_CFLAGS = -fobjc-arc -I. -include macros.h

include $(THEOS_MAKE_PATH)/tweak.mk
