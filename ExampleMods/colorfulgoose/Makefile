INSTALL_TARGET_PROCESSES = SpringBoard
TARGET = iphone:11.2:8.0
ARCHS = arm64e arm64 armv7

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ColorfulGoose
ColorfulGoose_FILES = PXColorfulGoose.m
ColorfulGoose_CFLAGS = -fobjc-arc
ColorfulGoose_INSTALL_PATH = /Library/MobileGoose/Mods
ColorfulGoose_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/bundle.mk
