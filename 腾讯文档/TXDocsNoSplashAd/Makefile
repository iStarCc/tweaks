ARCHS = arm64
TARGET := iphone:clang:latest:17.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TXDocsNoSplashAd

TXDocsNoSplashAd_FILES = Tweak.x
TXDocsNoSplashAd_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
