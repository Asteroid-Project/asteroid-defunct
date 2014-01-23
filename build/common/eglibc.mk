PACKAGE_NAME=eglibc
PACKAGE_VERSION=2.18
PACKAGE_URL=http://placeholder.fr/~leo/eglibc-2.18.tar.gz
SEPARATE_BUILD_DIR=TRUE

# The libc itself is in a subfolder of
# eglibc's main source directory
PRE_CONF="cd libc/"
