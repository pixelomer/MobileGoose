TARGET = iphone:11.2:8.0
ARCHS = arm64 arm64e armv7

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = NameTagMod

NameTagMod_FILES = PXNameTagMod.m
NameTagMod_CFLAGS = -fobjc-arc
NameTagMod_INSTALL_PATH = /Library/Application Support/MobileGoose/Mods/NameTagMod.bundle

include $(THEOS_MAKE_PATH)/library.mk
