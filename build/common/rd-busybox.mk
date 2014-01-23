PACKAGE_NAME=busybox
PACKAGE_VERSION=1.22.1
PACKAGE_URL="http://busybox.net/downloads/busybox-1.22.1.tar.bz2"

BUILD_SCRIPT='
run_check "cp $ASTEROID/build/common/rd-busybox.config configs/asteroid_defconfig"
run_check "make asteroid_defconfig"
run_check "make -j$CORE_COUNT"

run_check "mkdir -pv $DESTDIR/bin"
run_check "cp -v busybox $DESTDIR/bin"'
