INSTALL_TARGET_PROCESSES = SpringBoard
TARGET = iphone:11.2:8.0
ARCHS = arm64e arm64 armv7

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = JoeTheGoose
JoeTheGoose_FILES = PXJoeTheGooseMod.m
JoeTheGoose_CFLAGS = -fobjc-arc
JoeTheGoose_INSTALL_PATH = /Library/MobileGoose/Mods
JoeTheGoose_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/bundle.mk
