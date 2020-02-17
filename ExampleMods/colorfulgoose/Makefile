TARGET = iphone:11.2:8.0
ARCHS = arm64 arm64e armv7

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = ColorfulGoose

ColorfulGoose_FILES = PXColorfulGooseMod.m
ColorfulGoose_CFLAGS = -fobjc-arc
ColorfulGoose_INSTALL_PATH = /Library/Application Support/MobileGoose/Mods/ColorfulGoose.bundle

include $(THEOS_MAKE_PATH)/library.mk
