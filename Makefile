GO_EASY_ON_ME=1
ARCHS = armv7 arm64
#TARGET = iphone:clang:latest:latest
THEOS_BUILD_DIR = Packages

include theos/makefiles/common.mk

TWEAK_NAME = Freyr
Freyr_FILES = Tweak.xm
Freyr_FILES += FreyrController.mm
Freyr_FILES += FreyrForecast.mm
Freyr_FILES += FreyrPreferences.mm
Freyr_FRAMEWORKS = UIKit CoreGraphics QuartzCore
Freyr_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += Preferences

include $(THEOS_MAKE_PATH)/aggregate.mk
