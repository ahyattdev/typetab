ARCHS = armv7 armv7s arm64
TARGET = iphone:clang:latest:8.0
PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)
DEBUG = 0
GO_EASY_ON_ME = 1
ADDITIONAL_CFLAGS = -fobjc-arc

include theos/makefiles/common.mk

TWEAK_NAME = TypeTab
TypeTab_FILES = Tweak.xm
TypeTab_FRAMEWORKS = Foundation UIKit CoreGraphics
TypeTab_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard; killall -9 backboardd"
