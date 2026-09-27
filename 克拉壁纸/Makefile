ARCHS = arm64 arm64e
TARGET := iphone:clang:16.5:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ClarityProTweak

ClarityProTweak_FILES = Tweak.x
ClarityProTweak_CFLAGS = -fobjc-arc
ClarityProTweak_FRAMEWORKS = Foundation UIKit
ClarityProTweak_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk
