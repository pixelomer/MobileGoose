INSTALL_TARGET_PROCESSES = SpringBoard

ifeq ($(THEOS_PACKAGE_SCHEME),rootless)
ARCHS = arm64 arm64e
TARGET = iphone:13.3:15.0
else
ARCHS = arm64 arm64e armv7
TARGET = iphone:13.3:8.0
endif

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ColorfulGoose
ColorfulGoose_FILES = PXColorfulGoose.m
ColorfulGoose_CFLAGS = -I../../Template -fobjc-arc
ColorfulGoose_INSTALL_PATH = /Library/MobileGoose/Mods
ColorfulGoose_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/bundle.mk
