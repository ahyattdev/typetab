ARCHS = armv7 armv7s arm64 arm64e
TARGET = iphone:clang:latest:8.0
PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)
THEOS_BUILD_DIR = debs

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TypeTab
TypeTab_FILES = 8.xm 9.xm 10-and-11.xm 12.xm 13.xm
TypeTab_FRAMEWORKS = Foundation UIKit CoreGraphics
TypeTab_LIBRARIES = substrate
TypeTab_LDFLAGS += -Wl,-segalign,4000

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard; killall -9 backboardd"
