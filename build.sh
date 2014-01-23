#!/bin/bash

# print an info message (in red)
info() {
    echo -e "\e[31m[INFO] $1\e[0m"
}

warn() {
    echo -e "\e[33m[WARN] $1\e[0m"
}

if [ "x$DEVICE" = "x" ]; then
    warn "No device specified, building for goldfish."
    warn "Set the device you want to build for with the \$DEVICE variable"
    export DEVICE=goldfish
fi

export DEVICE
export ASTEROID=$PWD

info "Welcome to the Asteroid build system."
info "Building for $DEVICE"

clean_archives() {
    echo "Removing all archives in $ASTEROID/.tmp"
    rm -rvf $ASTEROID/.tmp/*
}

clean_package() {
    echo "Cleaning package $1"
    cd $ASTEROID
    rm -rf $ASTEROID/$1
}

clean_all() {
    for i in `get_device_packages ramdisk`; do
        clear_vars
        source $i
        clean_package $PACKAGE_NAME
    done

    for i in `get_device_packages`; do
        clear_vars
        source $i
        clean_package $PACKAGE_NAME
    done

    echo "Removing installation directories..."
    echo "rm -rf $ASTEROID/ramdisk"; rm -rf $ASTEROID/ramdisk
    echo "rm -rf $ASTEROID/rootdir"; rm -rf $ASTEROID/rootdir

    echo "Removing generated images..."
    rm -vf $ASTEROID/ramdisk.img
    rm -vf $ASTEROID/rootdir.img
}

# setup basic environment variables for this device
# reads device/main.mk
setup_device() {
    source $ASTEROID/build/$DEVICE/main.mk

    if [ "x$DEVICE_ARCH" = "x" ]; then
        warn "No architecture specified in $DEVICE/main.mk."
        warn "Assuming it to be arm-linux-gueabihf"
        DEVICE_ARCH="arm-linux-gnueabihf"
    fi

    export CORE_COUNT=`grep -c ^processor /proc/cpuinfo`
    export CROSS_COMPILE="$DEVICE_ARCH-"
    export ARCH=`echo $DEVICE_ARCH | cut -d ':' -f 1`
    export CC="$DEVICE_ARCH-gcc"
    export DEVICE_ARCH
}

# check that the package provides the minimum
# required variables (name, version and URL)
check_required_vars() {
    for var in `echo "PACKAGE_NAME PACKAGE_VERSION PACKAGE_URL"`; do
        if [ "x${!var}" = "x" ]; then
            echo "Error: Required variable $var not set in $1"
            exit 1
        fi
    done
}

# unset environment variables set by a build.mk file to be able to
# run the build of the next package in a clean environment
clear_vars() {
    unset PACKAGE_NAME
    unset PACKAGE_VERSION
    unset PACKAGE_URL
    unset BUILD_SCRIPT
    unset EXTRA_CONF_FLAGS
    unset EXTRA_MAKE_VARS
    unset SEPARATE_BUILD_DIR
    unset PREFIX
    unset PRE_CONF
    unset PRE_MAKE
    unset PRE_INSTALL
    unset POST_INSTALL
}

# Check $? and abort compilation if -ne 0
# display $1 as an error message, and $2 as a
# detailed message
check_ret_with_err() {
    if [ $? -ne 0 ]; then
        echo Error: "$1"
        
        if [ "x$2" != "x" ]; then
            echo "$2"
        fi

        exit 1
    fi
}

# run $1 as command, check the return, and on failure,
# exits printing $2 and $3 as error messages
run_check() {
    echo "$1"

    if [ "x$VERBOSE" = "x" ]; then
        eval "$1" >> $ASTEROID/build.log 2>&1
    else
        eval "$1"
    fi

    check_ret_with_err "$2" "$3"
}

eval_check() {
    if [ "x$1" != "x" ]; then
        eval "$1"
        check_ret_with_err "$2" "$3"
    fi
}

# Builds a package using a build file
# $1 is the default DESTDIR value
# $2 is the default PREFIX value
build_package() {
    mkdir -pv $ASTEROID/.tmp
    cd $ASTEROID/.tmp
    ARCHIVE=`basename $PACKAGE_URL`

    if [ ! -f $ARCHIVE ]; then
        run_check "wget $PACKAGE_URL --timeout=10" \
            "failed to get $PACKAGE_URL" \
            "Check Internet connection and package build file"
    fi

    cd $ASTEROID

    if [ -e $PACKAGE_NAME ]; then
        cd $PACKAGE_NAME
    else
        mkdir -v $PACKAGE_NAME
        cd $PACKAGE_NAME

        run_check "tar xf $ASTEROID/.tmp/$ARCHIVE --strip-components=1" \
            "failed to extract package archive"
    fi

    if [ "x$BUILD_SCRIPT" != "x" ]; then
        # package has a custom installation script
        # just run it
        eval_check "$BUILD_SCRIPT" "custom build script failed."
    else
        # This package uses standard autotools
        eval_check "$PRE_CONF" "pre-configure command failed."

        if [ "x$PREFIX" = "x" ]; then
            PREFIX=$2
        fi

        # some packages require to be build in a separate directory
        CONF=./configure
        if [ "x$SEPARATE_BUILD_DIR" = "xTRUE" ]; then
            mkdir -v build/
            cd build/
            CONF=../configure
        fi
    
        run_check "$CONF --prefix=$PREFIX --host=$DEVICE_ARCH $EXTRA_CONF_FLAGS" \
            "configure failed for $PACKAGE_NAME"

        # some packages require additionnal commands before running make
        eval_check "$PRE_MAKE" "pre-make command failed."
        run_check "$EXTRA_MAKE_VARS make -j$CORE_COUNT" \
            "make failed for $PACKAGE_NAME"

        # install the package
        eval_check "$PRE_INSTALL" "pre-install command failed."
        run_check "make DESTDIR=$1 install" "installation failed for $PACKAGE_NAME"
        eval_check "$POST_INSTALL" "post-install command failed."
    fi

    echo "Package $PACKAGE_NAME was build successfully into $1"
} 

# set $PACKAGES to the list of packages required to build on $DEVICE
# ordered by priority
# if $1 is not "", then it returns packages for the ramdisk as well as common
# packages
get_device_packages() {
    unset PACKAGES

    for i in `ls $ASTEROID/build/{common,$DEVICE}/*.mk 2>/dev/null`; do
        # rd-*.mk files are for the ramdisk, so skin them unless 
        # the caller asked for them
        if [[ $i == $ASTEROID/build/common/rd-*.mk ]]; then
            if [[ "x$1" != "x" ]]; then
                echo "$i"
            fi
        else
            if [[ "x$1" = "x" ]]; then
                echo "$i"
            fi
        fi
    done
}

build_ramdisk() {
    mkdir -pv $ASTEROID/ramdisk
    export DESTDIR=$ASTEROID/ramdisk

    # determine which packages we will build
    for i in `get_device_packages ramdisk`; do
        clear_vars
        source $i
        check_required_vars $i

        info "Building package $PACKAGE_NAME $PACKAGE_VERSION for the ramdisk"

        build_package $ASTEROID/ramdisk /
    done
}

build_rootdir() {
    mkdir -pv $ASTEROID/rootdir
    export DESTDIR=$ASTEROID/rootdir
    export CC="$CC -Wl,--dynamic-linker=/system/lib/ld-linux-armhf.so.3"

    for i in `get_device_packages`; do
        if [[ $i == $ASTEROID/build/common/rd-*.mk ]]; then
            continue
        fi

        clear_vars
        source $i
        check_required_vars $i

        info "Building package $PACKAGE_NAME $PACKAGE_VERSION for the rootdir"

        build_package $ASTEROID/rootdir /system
    done
}

# finish installation by stripping binaries and libraries
# to reduce the size of the final system
strip_install() {
    cd $ASTEROID/ramdisk/bin
    find . -exec strip {} \;

    cd $ASTEROID/rootdir/system
    find bin/ -exec strip {} \;
    find lib/ -exec strip {} \;
}

# start with a clean log
rm -f $ASTEROID/build.log

for i in "$@"; do
    case "$i" in
        --verbose)
            export VERBOSE=y
            ;;

        --ramdisk)
            BUILD_ROOTDIR="n"
            unset BUILD_RAMDISK
            ;;

        --rootdir)
            BUILD_RAMDISK="n"
            unset BUILD_ROOTDIR
            ;;

        --clean)
            clean_all
            exit $?
            ;;

        --clean-archives)
            clean_archives
            exit $?
            ;;

        --clean-all)
            clean_archives | clean_all
            exit $?
            ;;
    esac
done

setup_device

if [ "x$BUILD_RAMDISK" != "xn" ]; then
    build_ramdisk
fi

if [ "x$BUILD_ROOTDIR" != "xn" ]; then
    build_rootdir
fi

strip_install

# generate ramdisk
cd $ASTEROID/ramdisk
run_check "mkdir -p dev proc sys"
run_check "ln -sf busybox bin/sh"
run_check "wget http://placeholder.fr/~kido/init -O init"
run_check "chmod +x init"
run_check "wget http://placeholder.fr/~kido/bootsplash -O bootsplash"
run_check "find . | cpio -o -H newc | gzip > ../ramdisk.img"

# setup root directory
cd $ASTEROID/rootdir
run_check "mkdir -p users/root"
run_check "ln -sf system/etc etc"
run_check "cp $ASTEROID/ramdisk/bin/busybox system/bin/"
run_check "echo root::0:0:root:/users/root:/system/bin/bash > etc/passwd"
run_check "echo #!/system/bin/bash > system/bin/init"
run_check "echo export PATH=/system/bin >> system/bin/init"
run_check "echo exec busybox getty -n -l /system/bin/bash 9600 /dev/ttyS2 >> system/bin/init"
run_check "chmod +x system/bin/init"

# generate root FS image
cd $ASTEROID
run_check "make_ext4fs -l 150M -b 4k root.img rootdir/"
run_check "tune2fs -c0 -i0 root.img"

info "Successfully generated root.img and ramdisk.img"
