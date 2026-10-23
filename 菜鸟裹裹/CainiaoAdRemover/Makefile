TARGET := iphone:clang:latest:15.0
INSTALL_TARGET_PROCESSES = Cainiao4iPhone
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CainiaoAdRemover

CainiaoAdRemover_FILES = Tweak.x
CainiaoAdRemover_FRAMEWORKS = WebKit
CainiaoAdRemover_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
