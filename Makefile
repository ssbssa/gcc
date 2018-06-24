
MYPKG=ssbssa-1
BUILD_BITS=32

SOURCE_DIR=src
SOURCE_DIR_ABS=$(abspath $(SOURCE_DIR))
BUILD_DIR=build$(BUILD_BITS)
BUILD_DIR_ABS=$(abspath $(BUILD_DIR))

BINUTILS_DIR=$(abspath binutils$(BUILD_BITS))
GCC_DIR=$(abspath gcc$(BUILD_BITS))
GDB_LIBS=$(abspath gdb-libs$(BUILD_BITS))
GDB_DIR=$(abspath gdb$(BUILD_BITS))

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


BINUTILS_VER=2.30
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

MINGW_W64_VER=5.0.4
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

GCC_VER=8.1.0
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

EXPAT_VER=2.2.5
EXPAT_SRC_DIR=expat-$(EXPAT_VER)
EXPAT_FILE=$(EXPAT_SRC_DIR).tar.bz2
EXPAT_CONF=$(SOURCE_DIR_ABS)/$(EXPAT_SRC_DIR)/configure \
	   --build=$(MYBUILD) --host=$(MYTARGET) \
	   --enable-static --disable-shared --prefix=$(GDB_LIBS)

PDCURSES_VER=3.4
PDCURSES_SRC_DIR=PDCurses-$(PDCURSES_VER)
PDCURSES_FILE=$(PDCURSES_SRC_DIR).tar.gz
PDCURSES_CONF=$(SOURCE_DIR_ABS)/$(PDCURSES_SRC_DIR)/configure \
	      --build=$(MYBUILD) --host=$(MYTARGET) \
	      --enable-static --disable-shared --prefix=$(GDB_LIBS)

ICONV_VER=1.15
ICONV_SRC_DIR=libiconv-$(ICONV_VER)
ICONV_FILE=$(ICONV_SRC_DIR).tar.gz
ICONV_CONF=$(SOURCE_DIR_ABS)/$(ICONV_SRC_DIR)/configure \
	   --build=$(MYBUILD) --host=$(MYTARGET) \
	   --enable-static --disable-shared --prefix=$(GDB_LIBS)

PYTHON_VER=2.7.13
PYTHON_FILE=python-$(PYTHON_VER)-w$(BUILD_BITS).tar.xz
PYTHON_DIR=Python27

GDB_VER=8.1
GDB_SRC_DIR=gdb-$(GDB_VER)
GDB_FILE=$(GDB_SRC_DIR).tar.xz
GDB_CONF=$(SOURCE_DIR_ABS)/$(GDB_SRC_DIR)/configure \
	 --build=$(MYBUILD) --host=$(MYTARGET) --target=$(MYTARGET) \
	 --disable-nls \
	 CPPFLAGS="-I$(GDB_LIBS)/include" LDFLAGS="-L$(GDB_LIBS)/lib" \
	 --enable-curses --enable-tui \
	 --with-libiconv-prefix=$(GDB_LIBS) \
	 --disable-install-libbfd --disable-install-libiberty \
	 --with-pkgversion=$(MYPKG)


all:
ifeq ($(GDB_ONLY),)
all: $(BUILD_DIR)/binutils-06-prefix.done
all: $(BUILD_DIR)/mingw-w64-05-headers-make-install.done
all: $(BUILD_DIR)/gcc-05-make-install-gcc.done
all: $(BUILD_DIR)/mingw-w64-08-crt-make-install.done
all: $(BUILD_DIR)/gcc-09-lto-plugin.done
endif
all: $(BUILD_DIR)/expat-05-make-install.done
all: $(BUILD_DIR)/pdcurses-04-make-install.done
all: $(BUILD_DIR)/iconv-05-make-install.done
all: $(BUILD_DIR)/gdb-05-make-install.done


$(SOURCE_DIR):
	@mkdir $@

$(BUILD_DIR):
	@mkdir $@


ifeq ($(GDB_ONLY),)

# binutils

$(SOURCE_DIR)/binutils-01-extract.done: | $(SOURCE_DIR) pkg/$(BINUTILS_FILE)
	tar -C $(SOURCE_DIR) -xJf pkg/$(BINUTILS_FILE)
	@touch $@

$(SOURCE_DIR)/binutils-02-patch-01-makeinfo.done: | $(SOURCE_DIR)/binutils-01-extract.done
	patch -d $(SOURCE_DIR)/$(BINUTILS_SRC_DIR) -p0 <patches/binutils/makeinfo.patch
	@touch $@

$(SOURCE_DIR)/binutils-02-patch-03-compress-debug-sections.done: | $(SOURCE_DIR)/binutils-02-patch-01-makeinfo.done
	patch -d $(SOURCE_DIR)/$(BINUTILS_SRC_DIR) -p0 <patches/binutils/compress-debug-sections.patch
	@touch $@

$(SOURCE_DIR)/binutils-02-patch-04-gc-exported-symbols.done: | $(SOURCE_DIR)/binutils-02-patch-03-compress-debug-sections.done
	patch -d $(SOURCE_DIR)/$(BINUTILS_SRC_DIR) -p1 <patches/binutils/Don-t-gc-exported-symbols.patch
	@touch $@

$(SOURCE_DIR)/binutils-02-patch-05-dynamic-base.done: | $(SOURCE_DIR)/binutils-02-patch-04-gc-exported-symbols.done
	patch -d $(SOURCE_DIR)/$(BINUTILS_SRC_DIR) -p0 <patches/binutils/dynamic-base.patch
	@touch $@

$(SOURCE_DIR)/binutils-02-patch-06-delay-load.done: | $(SOURCE_DIR)/binutils-02-patch-05-dynamic-base.done
	patch -d $(SOURCE_DIR)/$(BINUTILS_SRC_DIR) -p0 <patches/binutils/delay-load.patch
	@touch $@

$(SOURCE_DIR)/binutils-02-patch-07-ctor-list.done: | $(SOURCE_DIR)/binutils-02-patch-06-delay-load.done
	patch -d $(SOURCE_DIR)/$(BINUTILS_SRC_DIR) -p0 <patches/binutils/ctor-list.patch
	@touch $@

$(BUILD_DIR)/binutils-03-configure.done: | $(SOURCE_DIR)/binutils-02-patch-07-ctor-list.done
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

$(SOURCE_DIR)/mingw-w64-02-patch-09-dwmapi-iconic.done: | $(SOURCE_DIR)/mingw-w64-02-patch-08-fix-alignment.done
	patch -d $(SOURCE_DIR)/$(MINGW_W64_SRC_DIR) -p1 <patches/mingw-w64/0009-dwmapi-add-missing-Iconic-functions.patch
	@touch $@

$(SOURCE_DIR)/mingw-w64-02-patch-10-printf-out-of-bounds-access.done: | $(SOURCE_DIR)/mingw-w64-02-patch-09-dwmapi-iconic.done
	patch -d $(SOURCE_DIR)/$(MINGW_W64_SRC_DIR) -p1 <patches/mingw-w64/0010-fix-printf-out-of-bounds-access.patch
	@touch $@

$(SOURCE_DIR)/mingw-w64-02-patch-11-strndup-wcsndup.done: | $(SOURCE_DIR)/mingw-w64-02-patch-10-printf-out-of-bounds-access.done
	patch -d $(SOURCE_DIR)/$(MINGW_W64_SRC_DIR) -p1 <patches/mingw-w64/0011-add-strndup-wcsndup.patch
	@touch $@

$(SOURCE_DIR)/mingw-w64-02-patch-12-fix-wscanf.done: | $(SOURCE_DIR)/mingw-w64-02-patch-11-strndup-wcsndup.done
	patch -d $(SOURCE_DIR)/$(MINGW_W64_SRC_DIR) -p1 <patches/mingw-w64/0012-fix-wscanf.patch
	@touch $@

$(BUILD_DIR)/mingw-w64-03-headers-configure.done: | $(BUILD_DIR)/binutils-06-prefix.done $(SOURCE_DIR)/mingw-w64-02-patch-12-fix-wscanf.done
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

$(SOURCE_DIR)/gcc-02-patch-08-neg-offs.done: | $(SOURCE_DIR)/gcc-02-patch-07-diagnostic-color-console.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p0 <patches/gcc/negative-offsets-register-save-directives.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-09-function-cast.done: | $(SOURCE_DIR)/gcc-02-patch-08-neg-offs.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p0 <patches/gcc/function-cast.patch
	@touch $@

$(BUILD_DIR)/gcc-03-configure.done: | $(BUILD_DIR)/binutils-06-prefix.done $(BUILD_DIR)/mingw-w64-05-headers-make-install.done $(SOURCE_DIR)/gcc-02-patch-09-function-cast.done
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

else

$(SOURCE_DIR)/binutils-01-extract.done \
  $(SOURCE_DIR)/mingw-w64-01-extract.done \
  $(SOURCE_DIR)/gcc-01-extract-01-gcc.done \
  $(SOURCE_DIR)/gcc-01-extract-02-gmp.done \
  $(SOURCE_DIR)/gcc-01-extract-03-mpfr.done \
  $(SOURCE_DIR)/gcc-01-extract-04-mpc.done \
  $(SOURCE_DIR)/gcc-01-extract-05-isl.done \
  $(SOURCE_DIR)/binutils-02-patch-01-makeinfo.done \
  $(SOURCE_DIR)/binutils-02-patch-03-compress-debug-sections.done \
  $(SOURCE_DIR)/binutils-02-patch-04-gc-exported-symbols.done \
  $(SOURCE_DIR)/binutils-02-patch-05-dynamic-base.done \
  $(SOURCE_DIR)/binutils-02-patch-06-delay-load.done \
  $(SOURCE_DIR)/binutils-02-patch-07-ctor-list.done \
  $(SOURCE_DIR)/mingw-w64-02-patch-12-fix-wscanf.done \
  $(SOURCE_DIR)/gcc-02-patch-01-gengtype.done \
  $(SOURCE_DIR)/gcc-02-patch-02-relocate.done \
  $(SOURCE_DIR)/gcc-02-patch-03-lfs.done \
  $(SOURCE_DIR)/gcc-02-patch-04-make-rel-pref.done \
  $(SOURCE_DIR)/gcc-02-patch-05-diagnostic-color.done \
  $(SOURCE_DIR)/gcc-02-patch-06-fno-ident.done \
  $(SOURCE_DIR)/gcc-02-patch-07-diagnostic-color-console.done \
  $(SOURCE_DIR)/gcc-02-patch-08-neg-offs.done \
  $(SOURCE_DIR)/gcc-02-patch-09-function-cast.done \
  $(BUILD_DIR)/binutils-06-prefix.done \
  $(BUILD_DIR)/mingw-w64-05-headers-make-install.done \
  $(BUILD_DIR)/mingw-w64-08-crt-make-install.done \
  $(BUILD_DIR)/gcc-09-lto-plugin.done: \
  | $(SOURCE_DIR) $(BUILD_DIR)
	@touch $@

endif


# expat

$(SOURCE_DIR)/expat-01-extract.done: | pkg/$(EXPAT_FILE) $(SOURCE_DIR)/gcc-01-extract-05-isl.done
	tar -C $(SOURCE_DIR) -xjf pkg/$(EXPAT_FILE)
	@touch $@

$(BUILD_DIR)/expat-03-configure.done: | $(BUILD_DIR)/binutils-06-prefix.done $(BUILD_DIR)/mingw-w64-05-headers-make-install.done $(BUILD_DIR)/mingw-w64-08-crt-make-install.done $(BUILD_DIR)/gcc-09-lto-plugin.done $(SOURCE_DIR)/expat-01-extract.done
	@mkdir -p $(BUILD_DIR)/expat
	$(GCC_PATH) cd $(BUILD_DIR)/expat && $(EXPAT_CONF)
	@touch $@

$(BUILD_DIR)/expat-04-make.done: | $(BUILD_DIR)/expat-03-configure.done
	$(GCC_PATH) $(MAKE) -C $(BUILD_DIR)/expat
	@touch $@

$(BUILD_DIR)/expat-05-make-install.done: | $(BUILD_DIR)/expat-04-make.done
	$(GCC_PATH) $(MAKE) -C $(BUILD_DIR)/expat install
	@touch $@


# pdcurses

$(SOURCE_DIR)/pdcurses-01-extract.done: | pkg/$(PDCURSES_FILE) $(SOURCE_DIR)/expat-01-extract.done
	tar -C $(SOURCE_DIR) -xzf pkg/$(PDCURSES_FILE)
	@touch $@

$(SOURCE_DIR)/pdcurses-02-patch-01-tputs.done: | $(SOURCE_DIR)/pdcurses-01-extract.done
	patch -d $(SOURCE_DIR)/$(PDCURSES_SRC_DIR) -p1 <patches/pdcurses/0001-fix-tputs.patch
	@touch $@

$(SOURCE_DIR)/pdcurses-02-patch-02-save-screen.done: | $(SOURCE_DIR)/pdcurses-02-patch-01-tputs.done
	patch -d $(SOURCE_DIR)/$(PDCURSES_SRC_DIR) -p1 <patches/pdcurses/0002-always-save-screen-when-entering-curses-mode.patch
	@touch $@

$(SOURCE_DIR)/pdcurses-02-patch-03-save-full-screen.done: | $(SOURCE_DIR)/pdcurses-02-patch-02-save-screen.done
	patch -d $(SOURCE_DIR)/$(PDCURSES_SRC_DIR) -p1 <patches/pdcurses/0003-save-full-screen-buffer.patch
	@touch $@

$(SOURCE_DIR)/pdcurses-02-patch-04-debug.done: | $(SOURCE_DIR)/pdcurses-02-patch-03-save-full-screen.done
	patch -d $(SOURCE_DIR)/$(PDCURSES_SRC_DIR) -p1 <patches/pdcurses/0004-add-debug-information-in-release-build.patch
	@touch $@

$(SOURCE_DIR)/pdcurses-02-patch-05-no-keypad.done: | $(SOURCE_DIR)/pdcurses-02-patch-04-debug.done
	patch -d $(SOURCE_DIR)/$(PDCURSES_SRC_DIR) -p1 <patches/pdcurses/0005-no-keypad.patch
	@touch $@

$(SOURCE_DIR)/pdcurses-02-patch-06-ctrl-left-right.done: | $(SOURCE_DIR)/pdcurses-02-patch-05-no-keypad.done
	patch -d $(SOURCE_DIR)/$(PDCURSES_SRC_DIR) -p1 <patches/pdcurses/0006-ctrl-left-right.patch
	@touch $@

$(SOURCE_DIR)/pdcurses-02-patch-07-clear-page.done: | $(SOURCE_DIR)/pdcurses-02-patch-06-ctrl-left-right.done
	patch -d $(SOURCE_DIR)/$(PDCURSES_SRC_DIR) -p1 <patches/pdcurses/0007-clear-page.patch
	@touch $@

$(SOURCE_DIR)/pdcurses-02-patch-08-line-up.done: | $(SOURCE_DIR)/pdcurses-02-patch-07-clear-page.done
	patch -d $(SOURCE_DIR)/$(PDCURSES_SRC_DIR) -p1 <patches/pdcurses/0008-line-up.patch
	@touch $@

$(SOURCE_DIR)/pdcurses-02-patch-09-doupdate.done: | $(SOURCE_DIR)/pdcurses-02-patch-08-line-up.done
	patch -d $(SOURCE_DIR)/$(PDCURSES_SRC_DIR) -p1 <patches/pdcurses/0009-fix-doupdate.patch
	@touch $@

$(SOURCE_DIR)/pdcurses-02-patch-10-fix-wheel.done: | $(SOURCE_DIR)/pdcurses-02-patch-09-doupdate.done
	patch -d $(SOURCE_DIR)/$(PDCURSES_SRC_DIR) -p1 <patches/pdcurses/0010-fix-wheel.patch
	@touch $@

$(BUILD_DIR)/pdcurses-03-make.done: | $(BUILD_DIR)/binutils-06-prefix.done $(BUILD_DIR)/mingw-w64-05-headers-make-install.done $(BUILD_DIR)/mingw-w64-08-crt-make-install.done $(BUILD_DIR)/gcc-09-lto-plugin.done $(BUILD_DIR)/expat-05-make-install.done $(SOURCE_DIR)/pdcurses-02-patch-10-fix-wheel.done
	@mkdir -p $(BUILD_DIR)/pdcurses
	$(GCC_PATH) $(MAKE) -C $(BUILD_DIR)/pdcurses -f $(SOURCE_DIR_ABS)/$(PDCURSES_SRC_DIR)/win32/gccwin32.mak PDCURSES_SRCDIR=$(SOURCE_DIR_ABS)/$(PDCURSES_SRC_DIR) pdcurses.a
	@touch $@

$(BUILD_DIR)/pdcurses-04-make-install.done: | $(BUILD_DIR)/pdcurses-03-make.done
	$(SOURCE_DIR_ABS)/$(PDCURSES_SRC_DIR)/install-sh -d -m 755 $(GDB_LIBS)/include $(GDB_LIBS)/lib
	cd $(SOURCE_DIR_ABS)/$(PDCURSES_SRC_DIR) && ./install-sh -c -m 644 curses.h $(GDB_LIBS)/include/curses.h
	cd $(SOURCE_DIR_ABS)/$(PDCURSES_SRC_DIR) && ./install-sh -c -m 644 term.h $(GDB_LIBS)/include/term.h
	cd $(BUILD_DIR)/pdcurses && $(SOURCE_DIR_ABS)/$(PDCURSES_SRC_DIR)/install-sh -c -m 644 pdcurses.a $(GDB_LIBS)/lib/libcurses.a
	@touch $@

# iconv

$(SOURCE_DIR)/iconv-01-extract.done: | pkg/$(ICONV_FILE) $(SOURCE_DIR)/pdcurses-01-extract.done
	tar -C $(SOURCE_DIR) -xzf pkg/$(ICONV_FILE)
	@touch $@

$(BUILD_DIR)/iconv-03-configure.done: | $(BUILD_DIR)/binutils-06-prefix.done $(BUILD_DIR)/mingw-w64-05-headers-make-install.done $(BUILD_DIR)/mingw-w64-08-crt-make-install.done $(BUILD_DIR)/gcc-09-lto-plugin.done $(BUILD_DIR)/expat-03-configure.done $(BUILD_DIR)/pdcurses-04-make-install.done $(SOURCE_DIR)/iconv-01-extract.done
	@mkdir -p $(BUILD_DIR)/iconv
	$(GCC_PATH) cd $(BUILD_DIR)/iconv && $(ICONV_CONF)
	@touch $@

$(BUILD_DIR)/iconv-04-make.done: | $(BUILD_DIR)/iconv-03-configure.done
	$(GCC_PATH) $(MAKE) -C $(BUILD_DIR)/iconv
	@touch $@

$(BUILD_DIR)/iconv-05-make-install.done: | $(BUILD_DIR)/iconv-04-make.done
	$(GCC_PATH) $(MAKE) -C $(BUILD_DIR)/iconv install
	@touch $@


# python

$(GDB_LIBS)/$(PYTHON_DIR): | pkg/$(PYTHON_FILE) $(BUILD_DIR)/iconv-05-make-install.done
	tar -C $(GDB_LIBS) -xJf pkg/$(PYTHON_FILE)


# gdb

$(SOURCE_DIR)/gdb-01-extract.done: | pkg/$(GDB_FILE) $(SOURCE_DIR)/iconv-01-extract.done
	tar -C $(SOURCE_DIR) -xJf pkg/$(GDB_FILE)
	@touch $@

$(SOURCE_DIR)/gdb-02-patch-01-jit-installer.done: | $(SOURCE_DIR)/gdb-01-extract.done
	patch -d $(SOURCE_DIR)/$(GDB_SRC_DIR) -p1 <patches/gdb/0001-Add-install-uninstall-commands-for-JIT-debugger.patch
	@touch $@

$(SOURCE_DIR)/gdb-02-patch-02-doc.done: | $(SOURCE_DIR)/gdb-02-patch-01-jit-installer.done
	patch -d $(SOURCE_DIR)/$(GDB_SRC_DIR) -p1 <patches/gdb/0002-Only-build-missing-texi-files.patch
	@touch $@

$(SOURCE_DIR)/gdb-02-patch-03-tui-syntax-highlight.done: | $(SOURCE_DIR)/gdb-02-patch-02-doc.done
	patch -d $(SOURCE_DIR)/$(GDB_SRC_DIR) -p1 <patches/gdb/0003-Add-syntax-highlighting-for-TUI.patch
	@touch $@

$(SOURCE_DIR)/gdb-02-patch-04-clear-symbols.done: | $(SOURCE_DIR)/gdb-02-patch-03-tui-syntax-highlight.done
	patch -d $(SOURCE_DIR)/$(GDB_SRC_DIR) -p1 <patches/gdb/0004-Clear-symbols-if-executable-can-t-be-attached.patch
	@touch $@

$(SOURCE_DIR)/gdb-02-patch-05-thiscall.done: | $(SOURCE_DIR)/gdb-02-patch-04-clear-symbols.done
	patch -d $(SOURCE_DIR)/$(GDB_SRC_DIR) -p1 <patches/gdb/0005-Use-thiscall-calling-convention-for-class-members.patch
	@touch $@

$(SOURCE_DIR)/gdb-02-patch-06-userprofile-home.done: | $(SOURCE_DIR)/gdb-02-patch-05-thiscall.done
	patch -d $(SOURCE_DIR)/$(GDB_SRC_DIR) -p1 <patches/gdb/0006-Use-USERPROFILE-as-alternative-to-HOME.patch
	@touch $@

$(SOURCE_DIR)/gdb-02-patch-07-access-violation.done: | $(SOURCE_DIR)/gdb-02-patch-06-userprofile-home.done
	patch -d $(SOURCE_DIR)/$(GDB_SRC_DIR) -p1 <patches/gdb/0007-Show-details-for-access-violation.patch
	@touch $@

$(SOURCE_DIR)/gdb-02-patch-08-tui-multi-line-syntax.done: | $(SOURCE_DIR)/gdb-02-patch-07-access-violation.done
	patch -d $(SOURCE_DIR)/$(GDB_SRC_DIR) -p1 <patches/gdb/0008-Add-multi-line-syntax-highlighting-for-TUI.patch
	@touch $@

$(SOURCE_DIR)/gdb-02-patch-09-console-scroll.done: | $(SOURCE_DIR)/gdb-02-patch-08-tui-multi-line-syntax.done
	patch -d $(SOURCE_DIR)/$(GDB_SRC_DIR) -p1 <patches/gdb/0009-Use-page-up-down-to-scroll-in-console-buffer.patch
	@touch $@

$(SOURCE_DIR)/gdb-02-patch-10-resize-crashes.done: | $(SOURCE_DIR)/gdb-02-patch-09-console-scroll.done
	patch -d $(SOURCE_DIR)/$(GDB_SRC_DIR) -p1 <patches/gdb/0010-Fix-resize-crashes.patch
	@touch $@

$(SOURCE_DIR)/gdb-02-patch-11-tui-search.done: | $(SOURCE_DIR)/gdb-02-patch-10-resize-crashes.done
	patch -d $(SOURCE_DIR)/$(GDB_SRC_DIR) -p1 <patches/gdb/0011-Fix-search-for-TUI.patch
	@touch $@

$(SOURCE_DIR)/gdb-02-patch-12-ctrl-left-right.done: | $(SOURCE_DIR)/gdb-02-patch-11-tui-search.done
	patch -d $(SOURCE_DIR)/$(GDB_SRC_DIR) -p1 <patches/gdb/0012-Use-ctrl-left-right-to-move-to-previous-next-word.patch
	@touch $@

$(SOURCE_DIR)/gdb-02-patch-13-moving-cursor.done: | $(SOURCE_DIR)/gdb-02-patch-12-ctrl-left-right.done
	patch -d $(SOURCE_DIR)/$(GDB_SRC_DIR) -p1 <patches/gdb/0013-Display-cursor-when-moving.patch
	@touch $@

$(SOURCE_DIR)/gdb-02-patch-14-exec-point-highlight.done: | $(SOURCE_DIR)/gdb-02-patch-13-moving-cursor.done
	patch -d $(SOURCE_DIR)/$(GDB_SRC_DIR) -p1 <patches/gdb/0014-Don-t-highlight-wrong-execution-point.patch
	@touch $@

$(SOURCE_DIR)/gdb-02-patch-15-no-warn-debuglink.done: | $(SOURCE_DIR)/gdb-02-patch-14-exec-point-highlight.done
	patch -d $(SOURCE_DIR)/$(GDB_SRC_DIR) -p1 <patches/gdb/0015-Don-t-warn-for-debuglink-section.patch
	@touch $@

$(SOURCE_DIR)/gdb-02-patch-16-no-source-color.done: | $(SOURCE_DIR)/gdb-02-patch-15-no-warn-debuglink.done
	patch -d $(SOURCE_DIR)/$(GDB_SRC_DIR) -p1 <patches/gdb/0016-Fix-highlight-colors-for-empty-source-window.patch
	@touch $@

$(SOURCE_DIR)/gdb-02-patch-17-console-resize.done: | $(SOURCE_DIR)/gdb-02-patch-16-no-source-color.done
	patch -d $(SOURCE_DIR)/$(GDB_SRC_DIR) -p1 <patches/gdb/0017-Add-console-command-to-resize-console-window.patch
	@touch $@

$(SOURCE_DIR)/gdb-02-patch-18-tui-list-frame.done: | $(SOURCE_DIR)/gdb-02-patch-17-console-resize.done
	patch -d $(SOURCE_DIR)/$(GDB_SRC_DIR) -p1 <patches/gdb/0018-Restore-TUI-behavior-of-list-and-frame.patch
	@touch $@

$(SOURCE_DIR)/gdb-02-patch-19-tui-wheel.done: | $(SOURCE_DIR)/gdb-02-patch-18-tui-list-frame.done
	patch -d $(SOURCE_DIR)/$(GDB_SRC_DIR) -p1 <patches/gdb/0019-Use-mouse-wheel-in-TUI.patch
	@touch $@

$(SOURCE_DIR)/gdb-02-patch-20-thread-name.done: | $(SOURCE_DIR)/gdb-02-patch-19-tui-wheel.done
	patch -d $(SOURCE_DIR)/$(GDB_SRC_DIR) -p1 <patches/gdb/0020-Support-thread-names-in-gdbserver.patch
	@touch $@

$(SOURCE_DIR)/gdb-02-patch-21-readline-assert.done: | $(SOURCE_DIR)/gdb-02-patch-20-thread-name.done
	patch -d $(SOURCE_DIR)/$(GDB_SRC_DIR) -p1 <patches/gdb/0021-Fix-readline-assert.patch
	@touch $@

$(SOURCE_DIR)/gdb-02-patch-22-memory-leaks.done: | $(SOURCE_DIR)/gdb-02-patch-21-readline-assert.done
	patch -d $(SOURCE_DIR)/$(GDB_SRC_DIR) -p1 <patches/gdb/0022-Fix-memory-leaks.patch
	@touch $@

$(SOURCE_DIR)/gdb-02-patch-23-scrolling-tui.done: | $(SOURCE_DIR)/gdb-02-patch-22-memory-leaks.done
	patch -d $(SOURCE_DIR)/$(GDB_SRC_DIR) -p1 <patches/gdb/0023-Fix-scrolling-in-TUI.patch
	@touch $@

$(SOURCE_DIR)/gdb-02-patch-24-no-segment-registers-win64.done: | $(SOURCE_DIR)/gdb-02-patch-23-scrolling-tui.done
	patch -d $(SOURCE_DIR)/$(GDB_SRC_DIR) -p1 <patches/gdb/0024-No-segment-registers-for-win64.patch
	@touch $@

$(BUILD_DIR)/gdb-03-configure.done: | $(BUILD_DIR)/binutils-06-prefix.done $(BUILD_DIR)/mingw-w64-05-headers-make-install.done $(BUILD_DIR)/mingw-w64-08-crt-make-install.done $(BUILD_DIR)/gcc-09-lto-plugin.done $(BUILD_DIR)/expat-05-make-install.done $(BUILD_DIR)/pdcurses-04-make-install.done $(BUILD_DIR)/iconv-05-make-install.done $(SOURCE_DIR)/gdb-02-patch-24-no-segment-registers-win64.done
	@mkdir -p $(BUILD_DIR)/gdb
	$(GCC_PATH) cd $(BUILD_DIR)/gdb && $(GDB_CONF) --prefix=$(GDB_DIR)
	@touch $@

$(BUILD_DIR)/gdb-04-make.done: | $(BUILD_DIR)/gdb-03-configure.done
	$(GCC_PATH) $(MAKE) CC_FOR_BUILD=$(MYBUILD)-gcc -C $(BUILD_DIR)/gdb
	@touch $@

$(BUILD_DIR)/gdb-05-make-install.done: | $(BUILD_DIR)/gdb-04-make.done
	$(GCC_PATH) $(MAKE) -C $(BUILD_DIR)/gdb/gdb install-strip
	@touch $@


# gdb-python

$(BUILD_DIR)/gdb-python-01-configure.done: | $(BUILD_DIR)/binutils-06-prefix.done $(BUILD_DIR)/mingw-w64-05-headers-make-install.done $(BUILD_DIR)/mingw-w64-08-crt-make-install.done $(BUILD_DIR)/gcc-09-lto-plugin.done $(BUILD_DIR)/expat-05-make-install.done $(BUILD_DIR)/pdcurses-04-make-install.done $(BUILD_DIR)/iconv-05-make-install.done $(SOURCE_DIR)/gdb-02-patch-24-no-segment-registers-win64.done $(GDB_LIBS)/$(PYTHON_DIR)
	@mkdir -p $(BUILD_DIR)/gdb-python
	$(GCC_PATH) cd $(BUILD_DIR)/gdb-python && $(GDB_CONF) --prefix=$(GDB_DIR)-python --with-python=$(GDB_LIBS)/$(PYTHON_DIR)/python
	@touch $@

$(BUILD_DIR)/gdb-python-02-make.done: | $(BUILD_DIR)/gdb-python-01-configure.done
	$(GCC_PATH) $(MAKE) CC_FOR_BUILD=$(MYBUILD)-gcc -C $(BUILD_DIR)/gdb-python
	@touch $@

$(BUILD_DIR)/gdb-python-03-make-install.done: | $(BUILD_DIR)/gdb-python-02-make.done
	$(GCC_PATH) $(MAKE) -C $(BUILD_DIR)/gdb-python/gdb install-strip
	@touch $@

$(BUILD_DIR)/gdb-python-04-python.done: | $(BUILD_DIR)/gdb-python-03-make-install.done
	cp -af $(GDB_LIBS)/$(PYTHON_DIR)/python27.dll $(GDB_DIR)-python/bin/
	cp -arf $(GDB_LIBS)/$(PYTHON_DIR)/Lib $(GDB_DIR)-python/lib
	rm -rf $(GDB_DIR)-python/lib/test
	@touch $@


extract-all: | \
  $(SOURCE_DIR)/binutils-01-extract.done \
  $(SOURCE_DIR)/mingw-w64-01-extract.done \
  $(SOURCE_DIR)/gcc-01-extract-01-gcc.done \
  $(SOURCE_DIR)/gcc-01-extract-02-gmp.done \
  $(SOURCE_DIR)/gcc-01-extract-03-mpfr.done \
  $(SOURCE_DIR)/gcc-01-extract-04-mpc.done \
  $(SOURCE_DIR)/gcc-01-extract-05-isl.done \
  $(SOURCE_DIR)/expat-01-extract.done \
  $(SOURCE_DIR)/pdcurses-01-extract.done \
  $(SOURCE_DIR)/iconv-01-extract.done \
  $(SOURCE_DIR)/gdb-01-extract.done \


patch-all: | \
  $(SOURCE_DIR)/binutils-02-patch-07-ctor-list.done \
  $(SOURCE_DIR)/mingw-w64-02-patch-12-fix-wscanf.done \
  $(SOURCE_DIR)/gcc-02-patch-09-function-cast.done \
  $(SOURCE_DIR)/pdcurses-02-patch-10-fix-wheel.done \
  $(SOURCE_DIR)/gdb-02-patch-24-no-segment-registers-win64.done \


build-binutils: | $(BUILD_DIR)/binutils-06-prefix.done
build-mingw-w64-headers: | $(BUILD_DIR)/mingw-w64-05-headers-make-install.done
build-gcc: | $(BUILD_DIR)/gcc-05-make-install-gcc.done
build-mingw-w64-crt: | $(BUILD_DIR)/mingw-w64-08-crt-make-install.done
build-gcc-full: | $(BUILD_DIR)/gcc-09-lto-plugin.done
build-expat: | $(BUILD_DIR)/expat-05-make-install.done
build-pdcurses: | $(BUILD_DIR)/pdcurses-04-make-install.done
build-iconv: | $(BUILD_DIR)/iconv-05-make-install.done
build-gdb: | $(BUILD_DIR)/gdb-05-make-install.done
build-gdb-python: | $(BUILD_DIR)/gdb-python-04-python.done


binutils$(BUILD_BITS).7z: | build-binutils
	@rm -f $@
	cd $(BINUTILS_DIR) && 7z a -mx=9 ../$@ *

gcc$(BUILD_BITS).7z: | build-gcc-full
	@rm -f $@
	cd $(GCC_DIR)/mingw && 7z a -mx=9 ../../$@ *

gdb$(BUILD_BITS).7z: | build-gdb
	@rm -f $@
	cd $(GDB_DIR) && 7z a -mx=9 ../$@ *

gdb$(BUILD_BITS)-python.7z: | build-gdb-python
	@rm -f $@
	cd $(GDB_DIR)-python && 7z a -mx=9 ../$@ *


package-binutils: binutils$(BUILD_BITS).7z
package-gcc: gcc$(BUILD_BITS).7z
package-gdb: gdb$(BUILD_BITS).7z
package-gdb-python: gdb$(BUILD_BITS)-python.7z

ifeq ($(GDB_ONLY),)
packages: package-binutils
packages: package-gcc
endif
packages: package-gdb
packages: package-gdb-python


info:
	@echo -e "\r"
	@echo -e "$(BINUTILS_FILE)\r"
	@echo -e "$(MINGW_W64_FILE)\r"
	@echo -e "$(GCC_FILE)\r"
	@echo -e "$(GMP_FILE)\r"
	@echo -e "$(MPFR_FILE)\r"
	@echo -e "$(MPC_FILE)\r"
	@echo -e "$(ISL_FILE)\r"
	@echo -e "$(EXPAT_FILE)\r"
	@echo -e "$(PDCURSES_FILE)\r"
	@echo -e "$(ICONV_FILE)\r"
	@echo -e "$(PYTHON_FILE)\r"
	@echo -e "$(GDB_FILE)\r"
