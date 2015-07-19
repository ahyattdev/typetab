export ARCHS = armv7 armv7s arm64
export SDKVERSION = 8.4
export TARGET = iphone:clang:8.4:8.0
export TARGET_IPHONEOS_DEPLOYMENT_VERSION = 8.0

export TWEAK_NAME = TypeTab
export TypeTab_FILES = Tweak.xm
export TypeTab_FRAMEWORKS = Foundation UIKit CoreGraphics
export PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard; killall -9 backboardd"
