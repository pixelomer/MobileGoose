include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = MobileGoose

MobileGoose_FILES = $(wildcard *.m) $(wildcard *.mm)
MobileGoose_INSTALL_PATH = /Library/PreferenceBundles
MobileGoose_FRAMEWORKS = UIKit
MobileGoose_LIBRARIES = substrate
MobileGoose_PRIVATE_FRAMEWORKS = Preferences
MobileGoose_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/MobileGoose.plist$(ECHO_END)
