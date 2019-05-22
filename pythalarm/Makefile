ARCHS = armv7 arm64
TARGET= iphone:9.2
include ~/theos/makefiles/common.mk


BUNDLE_NAME = PythAlarm
PythAlarm_FILES = PythAlarm.mm
PythAlarm_INSTALL_PATH = /Library/PreferenceBundles
PythAlarm_FRAMEWORKS = UIKit
PythAlarm_LDFLAGS += -Wl,-segalign,4000
PythAlarm_PRIVATE_FRAMEWORKS = Preferences
include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PythAlarm.plist$(ECHO_END)


	