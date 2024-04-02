ifeq ($(THEOS_PACKAGE_SCHEME),rootless)
ARCHS = arm64 arm64e
TARGET = iphone:13.3:15.0
# setWindow:, openURL:, etc. are required for rootful iOS 8.0
# but rootless works on iOS 15.0 and higher
CFLAGS = -Wno-deprecated-declarations
else
ARCHS = arm64 arm64e armv7
TARGET = iphone:13.3:8.0
CFLAGS =
# UIWindowScene
Tweak.xm_CFLAGS = -Wno-unguarded-availability-new
endif

INSTALL_TARGET_PROCESSES = SpringBoard
export TARGET ARCHS CFLAGS

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MobileGoose

MobileGoose_FRAMEWORKS = UIKit Foundation
MobileGoose_FILES = Tweak.xm $(wildcard Goose/*.mm)
MobileGoose_CFLAGS = -fobjc-arc -I. -include macros.h -ferror-limit=0

include $(THEOS_MAKE_PATH)/tweak.mk

ifeq ($(THEOS_PACKAGE_SCHEME),rootless)

internal-stage::
	mkdir -p layout/DEBIAN
	echo "interest /var/jb/Library/MobileGoose/Mods" > layout/DEBIAN/triggers
	cp -pv postinst.rootless layout/DEBIAN/postinst

else

internal-stage::
	mkdir -p layout/DEBIAN
	echo "interest /Library/MobileGoose/Mods" > layout/DEBIAN/triggers
	cp -pv postinst.rootful layout/DEBIAN/postinst

endif

SUBPROJECTS += Prefs
include $(THEOS_MAKE_PATH)/aggregate.mk
