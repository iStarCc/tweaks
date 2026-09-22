ARCHS = arm64 arm64e
TARGET := iphone:clang:16.5:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = QQNewsTweak

QQNewsTweak_FILES = Tweak.x
QQNewsTweak_CFLAGS = -fobjc-arc
QQNewsTweak_FRAMEWORKS = UIKit
QQNewsTweak_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk
