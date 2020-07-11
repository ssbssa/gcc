
MYPKG=ssbssa-1
BUILD_BITS=32

SOURCE_DIR=src
SOURCE_DIR_ABS=$(abspath $(SOURCE_DIR))
BUILD_DIR=build$(BUILD_BITS)
BUILD_DIR_ABS=$(abspath $(BUILD_DIR))

BINUTILS_DIR=$(abspath binutils$(BUILD_BITS))
GCC_DIR=$(abspath gcc$(BUILD_BITS))

ifeq ($(BUILD_BITS),32)
  MYBUILD=i686-w64-mingw32
  MYTARGET=i686-w64-mingw32
  DISABLE_LIB=--disable-lib64
else ifeq ($(BUILD_BITS),64)
  MYBUILD=i686-w64-mingw32
  MYTARGET=x86_64-w64-mingw32
  DISABLE_LIB=--disable-lib32
else
  $(error BUILD_BITS is $(BUILD_BITS))
endif


BINUTILS_VER=2.34
BINUTILS_SRC_DIR=binutils-$(BINUTILS_VER)
BINUTILS_FILE=$(BINUTILS_SRC_DIR).tar.xz
BINUTILS_CONF=$(SOURCE_DIR_ABS)/$(BINUTILS_SRC_DIR)/configure \
	      --build=$(MYBUILD) --target=$(MYTARGET) \
	      --disable-multilib --with-sysroot=$(BINUTILS_DIR) \
	      --prefix=$(BINUTILS_DIR) --enable-targets=$(MYTARGET) \
	      --disable-werror --disable-nls \
	      --disable-install-libbfd --disable-install-libiberty \
	      --enable-lto --enable-plugins
BINUTILS_PATH=export PATH="$(BINUTILS_DIR)/bin:$(PATH)";

MINGW_W64_VER=7.0.0
MINGW_W64_SRC_DIR=mingw-w64-v$(MINGW_W64_VER)
MINGW_W64_FILE=$(MINGW_W64_SRC_DIR).tar.bz2
MINGW_W64_HEADERS_CONF=$(SOURCE_DIR_ABS)/$(MINGW_W64_SRC_DIR)/mingw-w64-headers/configure \
		       --build=$(MYBUILD) --host=$(MYTARGET) \
		       --prefix=$(GCC_DIR)/mingw/$(MYTARGET)
MINGW_W64_CRT_CONF=$(SOURCE_DIR_ABS)/$(MINGW_W64_SRC_DIR)/mingw-w64-crt/configure \
		   --build=$(MYBUILD) --host=$(MYTARGET) \
		   --with-sysroot=$(GCC_DIR) \
		   --prefix=$(GCC_DIR)/mingw/$(MYTARGET) \
		   $(DISABLE_LIB)

GCC_VER=10.1.0
GCC_SRC_DIR=gcc-$(GCC_VER)
GCC_FILE=$(GCC_SRC_DIR).tar.xz
GCC_CONF=$(SOURCE_DIR_ABS)/$(GCC_SRC_DIR)/configure \
	 --build=$(MYBUILD) --target=$(MYTARGET) \
	 --disable-multilib --with-sysroot=$(GCC_DIR) \
	 --prefix=$(GCC_DIR)/mingw --enable-targets=$(MYTARGET) \
	 --enable-languages=c,c++ --disable-win32-registry --disable-nls \
	 --disable-bootstrap --enable-lto --enable-fully-dynamic-string \
	 --with-gnu-ld --disable-symvers --disable-werror --disable-shared \
	 --disable-version-specific-runtime-libs \
	 --with-pkgversion=$(MYPKG)
GCC_PATH=export PATH="$(GCC_DIR)/mingw/bin:$(BINUTILS_DIR)/bin:$(PATH)";

GMP_VER=6.1.2
GMP_SRC_DIR=gmp-$(GMP_VER)
GMP_FILE=$(GMP_SRC_DIR).tar.xz

MPFR_VER=3.1.6
MPFR_SRC_DIR=mpfr-$(MPFR_VER)
MPFR_FILE=$(MPFR_SRC_DIR).tar.xz

MPC_VER=1.0.3
MPC_SRC_DIR=mpc-$(MPC_VER)
MPC_FILE=$(MPC_SRC_DIR).tar.gz

ISL_VER=0.18
ISL_SRC_DIR=isl-$(ISL_VER)
ISL_FILE=$(ISL_SRC_DIR).tar.xz


all:
all: $(BUILD_DIR)/binutils-06-prefix.done
all: $(BUILD_DIR)/mingw-w64-05-headers-make-install.done
all: $(BUILD_DIR)/gcc-05-make-install-gcc.done
all: $(BUILD_DIR)/mingw-w64-08-crt-make-install.done
all: $(BUILD_DIR)/gcc-09-lto-plugin.done


$(SOURCE_DIR):
	@mkdir $@

$(BUILD_DIR):
	@mkdir $@


# binutils

$(SOURCE_DIR)/binutils-01-extract.done: | $(SOURCE_DIR) pkg/$(BINUTILS_FILE)
	tar -C $(SOURCE_DIR) -xJf pkg/$(BINUTILS_FILE)
	@touch $@

$(SOURCE_DIR)/binutils-02-patch-01-makeinfo.done: | $(SOURCE_DIR)/binutils-01-extract.done
	patch -d $(SOURCE_DIR)/$(BINUTILS_SRC_DIR) -p0 <patches/binutils/makeinfo.patch
	@touch $@

$(SOURCE_DIR)/binutils-02-patch-04-gc-exported-symbols.done: | $(SOURCE_DIR)/binutils-02-patch-01-makeinfo.done
	patch -d $(SOURCE_DIR)/$(BINUTILS_SRC_DIR) -p1 <patches/binutils/Don-t-gc-exported-symbols.patch
	@touch $@

$(SOURCE_DIR)/binutils-02-patch-06-delay-load.done: | $(SOURCE_DIR)/binutils-02-patch-04-gc-exported-symbols.done
	patch -d $(SOURCE_DIR)/$(BINUTILS_SRC_DIR) -p0 <patches/binutils/delay-load.patch
	@touch $@

$(BUILD_DIR)/binutils-03-configure.done: | $(SOURCE_DIR)/binutils-02-patch-06-delay-load.done
	@mkdir -p $(BUILD_DIR)/binutils
	cd $(BUILD_DIR)/binutils && $(BINUTILS_CONF)
	@touch $@

$(BUILD_DIR)/binutils-04-make.done: | $(BUILD_DIR)/binutils-03-configure.done
	$(MAKE) -C $(BUILD_DIR)/binutils
	@touch $@

$(BUILD_DIR)/binutils-05-make-install.done: | $(BUILD_DIR)/binutils-04-make.done
	$(MAKE) -C $(BUILD_DIR)/binutils install-strip
	@touch $@

ifeq ($(BUILD_BITS),64)

$(BUILD_DIR)/binutils-06-prefix.done: | $(BUILD_DIR)/binutils-05-make-install.done
	cd $(BINUTILS_DIR)/bin && for f in x86_64-w64-mingw32-*.exe; do cp $$f `echo $$f |sed 's/x86_64-w64-mingw32-//'`; done
	@touch $@

else

$(BUILD_DIR)/binutils-06-prefix.done: | $(BUILD_DIR)/binutils-05-make-install.done
	cd $(BINUTILS_DIR)/bin && util_bins="`echo *.exe`"; for f in $$util_bins; do cp $$f i686-w64-mingw32-$$f; done
	@touch $@

endif


# mingw-w64 headers

$(SOURCE_DIR)/mingw-w64-01-extract.done: | pkg/$(MINGW_W64_FILE) $(SOURCE_DIR)/binutils-01-extract.done
	tar -C $(SOURCE_DIR) -xjf pkg/$(MINGW_W64_FILE)
	@touch $@

$(SOURCE_DIR)/mingw-w64-02-patch-01-stpcpy-wcpcpy.done: | $(SOURCE_DIR)/mingw-w64-01-extract.done
	patch -d $(SOURCE_DIR)/$(MINGW_W64_SRC_DIR) -p1 <patches/mingw-w64/0001-add-stpcpy-wcpcpy.patch
	@touch $@

$(SOURCE_DIR)/mingw-w64-02-patch-02-_fpreset.done: | $(SOURCE_DIR)/mingw-w64-02-patch-01-stpcpy-wcpcpy.done
	patch -d $(SOURCE_DIR)/$(MINGW_W64_SRC_DIR) -p1 <patches/mingw-w64/0002-fix-_fpreset.patch
	@touch $@

$(SOURCE_DIR)/mingw-w64-02-patch-03-binmode.done: | $(SOURCE_DIR)/mingw-w64-02-patch-02-_fpreset.done
	patch -d $(SOURCE_DIR)/$(MINGW_W64_SRC_DIR) -p1 <patches/mingw-w64/0003-fix-binmode.patch
	@touch $@

$(SOURCE_DIR)/mingw-w64-02-patch-04-remove-error-handlers.done: | $(SOURCE_DIR)/mingw-w64-02-patch-03-binmode.done
	patch -d $(SOURCE_DIR)/$(MINGW_W64_SRC_DIR) -p1 <patches/mingw-w64/0004-remove-error-handlers.patch
	@touch $@

$(SOURCE_DIR)/mingw-w64-02-patch-05-_vswprintf.done: | $(SOURCE_DIR)/mingw-w64-02-patch-04-remove-error-handlers.done
	patch -d $(SOURCE_DIR)/$(MINGW_W64_SRC_DIR) -p1 <patches/mingw-w64/0005-fix-_vswprintf.patch
	@touch $@

$(SOURCE_DIR)/mingw-w64-02-patch-06-use-_TCHAR-for-argv.done: | $(SOURCE_DIR)/mingw-w64-02-patch-05-_vswprintf.done
	patch -d $(SOURCE_DIR)/$(MINGW_W64_SRC_DIR) -p1 <patches/mingw-w64/0006-use-_TCHAR-for-argv.patch
	@touch $@

$(SOURCE_DIR)/mingw-w64-02-patch-07-free-argv.done: | $(SOURCE_DIR)/mingw-w64-02-patch-06-use-_TCHAR-for-argv.done
	patch -d $(SOURCE_DIR)/$(MINGW_W64_SRC_DIR) -p1 <patches/mingw-w64/0007-free-argv.patch
	@touch $@

$(SOURCE_DIR)/mingw-w64-02-patch-08-fix-alignment.done: | $(SOURCE_DIR)/mingw-w64-02-patch-07-free-argv.done
	patch -d $(SOURCE_DIR)/$(MINGW_W64_SRC_DIR) -p1 <patches/mingw-w64/0008-fix-alignment-of-SETJMP_FLOAT128.patch
	@touch $@

$(SOURCE_DIR)/mingw-w64-02-patch-09-printf-out-of-bounds-access.done: | $(SOURCE_DIR)/mingw-w64-02-patch-08-fix-alignment.done
	patch -d $(SOURCE_DIR)/$(MINGW_W64_SRC_DIR) -p1 <patches/mingw-w64/0009-fix-printf-out-of-bounds-access.patch
	@touch $@

$(SOURCE_DIR)/mingw-w64-02-patch-10-strndup-wcsndup.done: | $(SOURCE_DIR)/mingw-w64-02-patch-09-printf-out-of-bounds-access.done
	patch -d $(SOURCE_DIR)/$(MINGW_W64_SRC_DIR) -p1 <patches/mingw-w64/0010-add-strndup-wcsndup.patch
	@touch $@

$(BUILD_DIR)/mingw-w64-03-headers-configure.done: | $(BUILD_DIR)/binutils-06-prefix.done $(SOURCE_DIR)/mingw-w64-02-patch-10-strndup-wcsndup.done
	@mkdir -p $(BUILD_DIR)/mingw-w64-headers
	$(BINUTILS_PATH) cd $(BUILD_DIR)/mingw-w64-headers && $(MINGW_W64_HEADERS_CONF)
	@touch $@

$(BUILD_DIR)/mingw-w64-04-headers-make.done: | $(BUILD_DIR)/mingw-w64-03-headers-configure.done
	$(BINUTILS_PATH) $(MAKE) -C $(BUILD_DIR)/mingw-w64-headers
	@touch $@

$(BUILD_DIR)/mingw-w64-05-headers-make-install.done: | $(BUILD_DIR)/mingw-w64-04-headers-make.done
	$(BINUTILS_PATH) $(MAKE) -C $(BUILD_DIR)/mingw-w64-headers install
	@touch $@


# gcc core

$(SOURCE_DIR)/gcc-01-extract-01-gcc.done: | pkg/$(GCC_FILE) $(SOURCE_DIR)/mingw-w64-01-extract.done
	tar -C $(SOURCE_DIR) -xJf pkg/$(GCC_FILE)
	@touch $@

$(SOURCE_DIR)/gcc-01-extract-02-gmp.done: | $(SOURCE_DIR)/gcc-01-extract-01-gcc.done pkg/$(GMP_FILE)
	tar -C $(SOURCE_DIR)/$(GCC_SRC_DIR) -xJf pkg/$(GMP_FILE)
	mv $(SOURCE_DIR)/$(GCC_SRC_DIR)/$(GMP_SRC_DIR) $(SOURCE_DIR)/$(GCC_SRC_DIR)/gmp
	@touch $@

$(SOURCE_DIR)/gcc-01-extract-03-mpfr.done: | $(SOURCE_DIR)/gcc-01-extract-02-gmp.done pkg/$(MPFR_FILE)
	tar -C $(SOURCE_DIR)/$(GCC_SRC_DIR) -xJf pkg/$(MPFR_FILE)
	mv $(SOURCE_DIR)/$(GCC_SRC_DIR)/$(MPFR_SRC_DIR) $(SOURCE_DIR)/$(GCC_SRC_DIR)/mpfr
	@touch $@

$(SOURCE_DIR)/gcc-01-extract-04-mpc.done: | $(SOURCE_DIR)/gcc-01-extract-03-mpfr.done pkg/$(MPC_FILE)
	tar -C $(SOURCE_DIR)/$(GCC_SRC_DIR) -xzf pkg/$(MPC_FILE)
	mv $(SOURCE_DIR)/$(GCC_SRC_DIR)/$(MPC_SRC_DIR) $(SOURCE_DIR)/$(GCC_SRC_DIR)/mpc
	@touch $@

$(SOURCE_DIR)/gcc-01-extract-05-isl.done: | $(SOURCE_DIR)/gcc-01-extract-04-mpc.done pkg/$(ISL_FILE)
	tar -C $(SOURCE_DIR)/$(GCC_SRC_DIR) -xJf pkg/$(ISL_FILE)
	mv $(SOURCE_DIR)/$(GCC_SRC_DIR)/$(ISL_SRC_DIR) $(SOURCE_DIR)/$(GCC_SRC_DIR)/isl
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-01-gengtype.done: | $(SOURCE_DIR)/gcc-01-extract-05-isl.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p0 <patches/gcc/gengtype.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-02-relocate.done: | $(SOURCE_DIR)/gcc-02-patch-01-gengtype.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/relocate.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-03-lfs.done: | $(SOURCE_DIR)/gcc-02-patch-02-relocate.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/lfs.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-04-make-rel-pref.done: | $(SOURCE_DIR)/gcc-02-patch-03-lfs.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/make-rel-pref.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-05-diagnostic-color.done: | $(SOURCE_DIR)/gcc-02-patch-04-make-rel-pref.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p0 <patches/gcc/diagnostic-color.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-06-fno-ident.done: | $(SOURCE_DIR)/gcc-02-patch-05-diagnostic-color.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p0 <patches/gcc/fno-ident.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-07-diagnostic-color-console.done: | $(SOURCE_DIR)/gcc-02-patch-06-fno-ident.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p0 <patches/gcc/diagnostic-color-console.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-08-function-cast.done: | $(SOURCE_DIR)/gcc-02-patch-07-diagnostic-color-console.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p0 <patches/gcc/function-cast.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-09-duplicate-Wformat.done: | $(SOURCE_DIR)/gcc-02-patch-08-function-cast.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p0 <patches/gcc/duplicate-Wformat.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-10-diagnostic-url.done: | $(SOURCE_DIR)/gcc-02-patch-09-duplicate-Wformat.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p0 <patches/gcc/diagnostic-url.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-11-diagnostic-url-html-page.done: | $(SOURCE_DIR)/gcc-02-patch-10-diagnostic-url.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/diagnostic-url-html-page.patch
	@touch $@

$(BUILD_DIR)/gcc-03-configure.done: | $(BUILD_DIR)/binutils-06-prefix.done $(BUILD_DIR)/mingw-w64-05-headers-make-install.done $(SOURCE_DIR)/gcc-02-patch-11-diagnostic-url-html-page.done
	@mkdir -p $(BUILD_DIR)/gcc $(GCC_DIR)/mingw/include
	$(BINUTILS_PATH) cd $(BUILD_DIR)/gcc && $(GCC_CONF)
	@touch $@

$(BUILD_DIR)/gcc-04-make-gcc.done: | $(BUILD_DIR)/gcc-03-configure.done
	$(BINUTILS_PATH) $(MAKE) -C $(BUILD_DIR)/gcc all-gcc
	@touch $@

$(BUILD_DIR)/gcc-05-make-install-gcc.done: | $(BUILD_DIR)/gcc-04-make-gcc.done
	$(BINUTILS_PATH) $(MAKE) -C $(BUILD_DIR)/gcc install-strip-gcc
	@touch $@


# mingw-w64 crt

$(BUILD_DIR)/mingw-w64-06-crt-configure.done: | $(BUILD_DIR)/binutils-06-prefix.done $(BUILD_DIR)/gcc-05-make-install-gcc.done $(BUILD_DIR)/mingw-w64-05-headers-make-install.done
	@mkdir -p $(BUILD_DIR)/mingw-w64-crt
	$(GCC_PATH) cd $(BUILD_DIR)/mingw-w64-crt && $(MINGW_W64_CRT_CONF)
	@touch $@

$(BUILD_DIR)/mingw-w64-07-crt-make.done: | $(BUILD_DIR)/mingw-w64-06-crt-configure.done
	$(GCC_PATH) $(MAKE) -C $(BUILD_DIR)/mingw-w64-crt
	@touch $@

$(BUILD_DIR)/mingw-w64-08-crt-make-install.done: | $(BUILD_DIR)/mingw-w64-07-crt-make.done
	$(GCC_PATH) $(MAKE) -C $(BUILD_DIR)/mingw-w64-crt install
	@touch $@


# gcc

$(BUILD_DIR)/gcc-06-make.done: | $(BUILD_DIR)/binutils-06-prefix.done $(BUILD_DIR)/mingw-w64-05-headers-make-install.done $(BUILD_DIR)/mingw-w64-08-crt-make-install.done $(BUILD_DIR)/gcc-05-make-install-gcc.done
	$(BINUTILS_PATH) $(MAKE) -C $(BUILD_DIR)/gcc
	@touch $@

$(BUILD_DIR)/gcc-07-make-install.done: | $(BUILD_DIR)/gcc-06-make.done
	$(BINUTILS_PATH) $(MAKE) -C $(BUILD_DIR)/gcc install-strip
	@touch $@

ifeq ($(BUILD_BITS),64)

$(BUILD_DIR)/gcc-08-remove-prefix.done: | $(BUILD_DIR)/gcc-07-make-install.done
	cd $(GCC_DIR)/mingw/bin && for f in x86_64-w64-mingw32-*.exe; do cp $$f `echo $$f |sed 's/x86_64-w64-mingw32-//'`; done
	@touch $@

else

$(BUILD_DIR)/gcc-08-remove-prefix.done: | $(BUILD_DIR)/gcc-07-make-install.done
	@touch $@

endif

$(BUILD_DIR)/gcc-09-lto-plugin.done: | $(BUILD_DIR)/gcc-08-remove-prefix.done
	@mkdir -p $(GCC_DIR)/mingw/lib/bfd-plugins
	cp -f $(GCC_DIR)/mingw/libexec/gcc/$(MYTARGET)/$(GCC_VER)/liblto_plugin-0.dll $(GCC_DIR)/mingw/lib/bfd-plugins/
	@touch $@


extract-all: | \
  $(SOURCE_DIR)/binutils-01-extract.done \
  $(SOURCE_DIR)/mingw-w64-01-extract.done \
  $(SOURCE_DIR)/gcc-01-extract-01-gcc.done \
  $(SOURCE_DIR)/gcc-01-extract-02-gmp.done \
  $(SOURCE_DIR)/gcc-01-extract-03-mpfr.done \
  $(SOURCE_DIR)/gcc-01-extract-04-mpc.done \
  $(SOURCE_DIR)/gcc-01-extract-05-isl.done \


patch-all: | \
  $(SOURCE_DIR)/binutils-02-patch-06-delay-load.done \
  $(SOURCE_DIR)/mingw-w64-02-patch-10-strndup-wcsndup.done \
  $(SOURCE_DIR)/gcc-02-patch-11-diagnostic-url-html-page.done \


build-binutils: | $(BUILD_DIR)/binutils-06-prefix.done
build-mingw-w64-headers: | $(BUILD_DIR)/mingw-w64-05-headers-make-install.done
build-gcc: | $(BUILD_DIR)/gcc-05-make-install-gcc.done
build-mingw-w64-crt: | $(BUILD_DIR)/mingw-w64-08-crt-make-install.done
build-gcc-full: | $(BUILD_DIR)/gcc-09-lto-plugin.done


binutils$(BUILD_BITS).7z: | build-binutils
	@rm -f $@
	cd $(BINUTILS_DIR) && 7z a -mx=9 ../$@ *

gcc$(BUILD_BITS).7z: | build-gcc-full
	@rm -f $@
	cd $(GCC_DIR)/mingw && 7z a -mx=9 ../../$@ *


package-binutils: binutils$(BUILD_BITS).7z
package-gcc: gcc$(BUILD_BITS).7z

packages: package-binutils
packages: package-gcc


info:
	@echo -e "\r"
	@echo -e "$(BINUTILS_FILE)\r"
	@echo -e "$(MINGW_W64_FILE)\r"
	@echo -e "$(GCC_FILE)\r"
	@echo -e "$(GMP_FILE)\r"
	@echo -e "$(MPFR_FILE)\r"
	@echo -e "$(MPC_FILE)\r"
	@echo -e "$(ISL_FILE)\r"
