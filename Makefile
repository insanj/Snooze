THEOS_PACKAGE_DIR_NAME = debs
TARGET = :clang
ARCHS = armv7 arm64

include theos/makefiles/common.mk

TWEAK_NAME = Snooze
Snooze_FILES = Snooze.xm
Snooze_FRAMEWORKS = UIKit Foundation
Snooze_PRIVATE_FRAMEWORKS = MobileTimer PersistentConnection

include $(THEOS_MAKE_PATH)/tweak.mk

internal-after-install::
	install.exec "killall -9 backboardd"
