PACKAGE_NAME=coreutils
PACKAGE_VERSION=8.22
PACKAGE_URL=http://ftp.gnu.org/gnu/coreutils/coreutils-8.22.tar.xz

PRE_CONF='
run_check "wget http://patches.cross-lfs.org/dev/coreutils-8.22-noman-1.patch -O coreutils-noman.patch"
patch -Np1 -i coreutils-noman.patch
true' # force the caller to continue in case of error from patch, as this
      # may occur if the patch is already applied, i.e. when rebuilding

