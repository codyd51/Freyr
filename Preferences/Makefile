ARCHS = armv7 arm64
TARGET = iphone:clang:latest:latest

include theos/makefiles/common.mk

BUNDLE_NAME = Freyr
Freyr_FILES = FreyrRootListController.m FreyrDiscreteSliderTableCell.m FreyrSocialCell.m FreyrHeaderCell.m
Freyr_INSTALL_PATH = /Library/PreferenceBundles
Freyr_FRAMEWORKS = UIKit CoreGraphics
Freyr_PRIVATE_FRAMEWORKS = Preferences
#Freyr_LIBRARIES = cephei
Freyr_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Freyr.plist$(ECHO_END)
