include theos/makefiles/common.mk

TWEAK_NAME = TypeTab
TypeTab_FILES = Tweak.xm
TypeTab_FRAMEWORKS = UIKit
include $(THEOS_MAKE_PATH)/tweak.mk

export ARCHS = armv7 armv7s arm64
export SDKVERSION = 8.2
export TARGET = iphone:clang:8.2:7.0
export TARGET_IPHONEOS_DEPLOYMENT_VERSION = 7.0
export THEOS_DEVICE_IP = talos.local

after-install::
	install.exec "killall -9 SpringBoard; killall -9 backboardd"
