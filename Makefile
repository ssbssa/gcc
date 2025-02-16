
MYPKG=ssbssa-1
BUILD_BITS=32

SOURCE_DIR=src
SOURCE_DIR_ABS=$(abspath $(SOURCE_DIR))
BUILD_DIR=build$(BUILD_BITS)
BUILD_DIR_ABS=$(abspath $(BUILD_DIR))

BINUTILS_DIR=$(abspath binutils$(BUILD_BITS))
GCC_DIR=$(abspath gcc$(BUILD_BITS))

ifeq ($(BUILD_BITS),32)
  BUILD_ARCH=i686
  MYBUILD=i686-w64-mingw32
  MYTARGET=i686-w64-mingw32
  DISABLE_LIB=--disable-lib64
  WINDRES_OVERRIDE=
else ifeq ($(BUILD_BITS),64)
  BUILD_ARCH=x86_64
  MYBUILD=i686-w64-mingw32
  MYTARGET=x86_64-w64-mingw32
  DISABLE_LIB=--disable-lib32
  WINDRES_OVERRIDE=WINDRES=$(MYBUILD)-windres
else
  $(error BUILD_BITS is $(BUILD_BITS))
endif


BINUTILS_VER=2.43.1
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

MINGW_W64_VER=12.0.0
MINGW_W64_SRC_DIR=mingw-w64-v$(MINGW_W64_VER)
MINGW_W64_FILE=$(MINGW_W64_SRC_DIR).tar.bz2
MINGW_W64_HEADERS_CONF=$(SOURCE_DIR_ABS)/$(MINGW_W64_SRC_DIR)/mingw-w64-headers/configure \
		       --build=$(MYBUILD) --host=$(MYTARGET) \
		       --with-default-win32-winnt=0x502 \
		       --with-default-msvcrt=msvcrt \
		       --prefix=$(GCC_DIR)/mingw/$(MYTARGET)
MINGW_W64_CRT_CONF=$(SOURCE_DIR_ABS)/$(MINGW_W64_SRC_DIR)/mingw-w64-crt/configure \
		   --build=$(MYBUILD) --host=$(MYTARGET) \
		   --with-sysroot=$(GCC_DIR) \
		   --with-default-msvcrt=msvcrt \
		   --prefix=$(GCC_DIR)/mingw/$(MYTARGET) \
		   $(DISABLE_LIB)

MCFGTHREAD_VER=releases-v1.6
MCFGTHREAD_SRC_DIR=mcfgthread-$(MCFGTHREAD_VER)
MCFGTHREAD_FILE=$(MCFGTHREAD_SRC_DIR).tar.gz
MCFGTHREAD_CONF=$(SOURCE_DIR_ABS)/$(MCFGTHREAD_SRC_DIR)/configure \
		   --build=$(MYBUILD) --host=$(MYTARGET) \
		   --enable-static --disable-shared \
		   --with-sysroot=$(GCC_DIR) \
		   --prefix=$(GCC_DIR)/mingw/$(MYTARGET)

GCC_VER=14.2.0
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
	 --enable-threads=mcf \
	 --disable-win32-utf8-manifest \
	 --with-pkgversion=$(MYPKG)
GCC_PATH=export PATH="$(GCC_DIR)/mingw/bin:$(BINUTILS_DIR)/bin:$(PATH)";

GMP_VER=6.2.1
GMP_SRC_DIR=gmp-$(GMP_VER)
GMP_FILE=$(GMP_SRC_DIR).tar.xz

MPFR_VER=4.1.0
MPFR_SRC_DIR=mpfr-$(MPFR_VER)
MPFR_FILE=$(MPFR_SRC_DIR).tar.xz

MPC_VER=1.2.1
MPC_SRC_DIR=mpc-$(MPC_VER)
MPC_FILE=$(MPC_SRC_DIR).tar.gz

ISL_VER=0.24
ISL_SRC_DIR=isl-$(ISL_VER)
ISL_FILE=$(ISL_SRC_DIR).tar.xz


all:
all: $(BUILD_DIR)/binutils-07-licenses.done
all: $(BUILD_DIR)/mingw-w64-05-headers-make-install.done
all: $(BUILD_DIR)/gcc-05-make-install-gcc.done
all: $(BUILD_DIR)/mingw-w64-08-crt-make-install.done
all: $(BUILD_DIR)/gcc-10-licenses.done


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

$(SOURCE_DIR)/binutils-02-patch-02-gc-exported-symbols.done: | $(SOURCE_DIR)/binutils-02-patch-01-makeinfo.done
	patch -d $(SOURCE_DIR)/$(BINUTILS_SRC_DIR) -p1 <patches/binutils/Don-t-gc-exported-symbols.patch
	@touch $@

$(SOURCE_DIR)/binutils-02-patch-03-delay-load.done: | $(SOURCE_DIR)/binutils-02-patch-02-gc-exported-symbols.done
	patch -d $(SOURCE_DIR)/$(BINUTILS_SRC_DIR) -p0 <patches/binutils/delay-load.patch
	@touch $@

$(SOURCE_DIR)/binutils-02-patch-04-objcopy-large-address-aware.done: | $(SOURCE_DIR)/binutils-02-patch-03-delay-load.done
	patch -d $(SOURCE_DIR)/$(BINUTILS_SRC_DIR) -p0 <patches/binutils/objcopy-large-address-aware.patch
	@touch $@

$(BUILD_DIR)/binutils-03-configure.done: | $(SOURCE_DIR)/binutils-02-patch-04-objcopy-large-address-aware.done
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

$(BUILD_DIR)/binutils-07-licenses.done: | $(BUILD_DIR)/binutils-06-prefix.done
	@mkdir -p $(BINUTILS_DIR)/share/licenses/binutils
	cp -p $(SOURCE_DIR_ABS)/$(BINUTILS_SRC_DIR)/COPYING3 $(BINUTILS_DIR)/share/licenses/binutils/
	@touch $@


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

$(SOURCE_DIR)/mingw-w64-02-patch-05-free-argv.done: | $(SOURCE_DIR)/mingw-w64-02-patch-04-remove-error-handlers.done
	patch -d $(SOURCE_DIR)/$(MINGW_W64_SRC_DIR) -p1 <patches/mingw-w64/0005-free-argv.patch
	@touch $@

$(SOURCE_DIR)/mingw-w64-02-patch-06-fix-alignment.done: | $(SOURCE_DIR)/mingw-w64-02-patch-05-free-argv.done
	patch -d $(SOURCE_DIR)/$(MINGW_W64_SRC_DIR) -p1 <patches/mingw-w64/0006-fix-alignment-of-SETJMP_FLOAT128.patch
	@touch $@

$(SOURCE_DIR)/mingw-w64-02-patch-07-printf-out-of-bounds-access.done: | $(SOURCE_DIR)/mingw-w64-02-patch-06-fix-alignment.done
	patch -d $(SOURCE_DIR)/$(MINGW_W64_SRC_DIR) -p1 <patches/mingw-w64/0007-fix-printf-out-of-bounds-access.patch
	@touch $@

$(SOURCE_DIR)/mingw-w64-02-patch-08-strndup-wcsndup.done: | $(SOURCE_DIR)/mingw-w64-02-patch-07-printf-out-of-bounds-access.done
	patch -d $(SOURCE_DIR)/$(MINGW_W64_SRC_DIR) -p1 <patches/mingw-w64/0008-add-strndup-wcsndup.patch
	@touch $@

$(SOURCE_DIR)/mingw-w64-02-patch-09-def.in-symbols.done: | $(SOURCE_DIR)/mingw-w64-02-patch-08-strndup-wcsndup.done
	patch -d $(SOURCE_DIR)/$(MINGW_W64_SRC_DIR) -p1 <patches/mingw-w64/0009-crt-Preprocess-all-.def.in-files-with-DDEF_-ARCH.patch
	@touch $@

$(BUILD_DIR)/mingw-w64-03-headers-configure.done: | $(BUILD_DIR)/binutils-07-licenses.done $(SOURCE_DIR)/mingw-w64-02-patch-09-def.in-symbols.done
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

$(SOURCE_DIR)/gcc-01-extract-01-gcc.done: | pkg/$(GCC_FILE) $(SOURCE_DIR)/mcfgthread-01-extract.done
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
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/0001-Fix-gengtype-for-windows-paths.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-02-relocate.done: | $(SOURCE_DIR)/gcc-02-patch-01-gengtype.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/0002-Relocatable-mingw-paths.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-03-lfs.done: | $(SOURCE_DIR)/gcc-02-patch-02-relocate.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/0003-Mingw-LFS-support.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-04-make-rel-pref.done: | $(SOURCE_DIR)/gcc-02-patch-03-lfs.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/0004-Fix-make-relative-prefix-for-Windows.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-05-diagnostic-color.done: | $(SOURCE_DIR)/gcc-02-patch-04-make-rel-pref.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/0005-Enable-diagnostic-colors-on-cygwin-terminal.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-06-diagnostic-color-console.done: | $(SOURCE_DIR)/gcc-02-patch-05-diagnostic-color.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/0006-Enable-diagnostic-colors-on-Windows-console.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-07-fno-ident.done: | $(SOURCE_DIR)/gcc-02-patch-06-diagnostic-color-console.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/0007-Disable-ident-directive-by-default.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-08-function-cast.done: | $(SOURCE_DIR)/gcc-02-patch-07-fno-ident.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/0008-Don-t-warn-for-function-casts-involving-FARPROC.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-09-duplicate-Wformat.done: | $(SOURCE_DIR)/gcc-02-patch-08-function-cast.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/0009-Fix-duplicate-Wformat-warnings-PR-c-92292.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-10-diagnostic-url.done: | $(SOURCE_DIR)/gcc-02-patch-09-duplicate-Wformat.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/0010-Enable-diagnostic-URLs-on-cygwin-terminal.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-11-Wunused-non-trivial.done: | $(SOURCE_DIR)/gcc-02-patch-10-diagnostic-url.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/0011-Warn-when-a-non-trivial-class-instance-is-unused-PR-.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-12-Wconversion-rshift.done: | $(SOURCE_DIR)/gcc-02-patch-11-Wunused-non-trivial.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/0012-Don-t-warn-if-the-result-of-a-right-shift-fits-in-th.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-13-loc-non-standard-suffix.done: | $(SOURCE_DIR)/gcc-02-patch-12-Wconversion-rshift.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/0013-Fix-source-location-of-non-standard-suffix-PR-c-9282.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-14-redefined-macro-warning.done: | $(SOURCE_DIR)/gcc-02-patch-13-loc-non-standard-suffix.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/0014-Create-switch-to-control-redefined-macro-warning-PR-.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-15-parameter-pack.done: | $(SOURCE_DIR)/gcc-02-patch-14-redefined-macro-warning.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/0015-Add-name-of-parameter-pack.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-16-tzdb-disabled.done: | $(SOURCE_DIR)/gcc-02-patch-15-parameter-pack.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/0016-Set-TZDB_DISABLED-if-_GLIBCXX_HAS_GTHREADS-is-not-av.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-17-getthreadid-alternative.done: | $(SOURCE_DIR)/gcc-02-patch-16-tzdb-disabled.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/0017-Add-GetThreadId-alternative-for-WinXP.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-18-mcf-sjlj-infinite-recursion.done: | $(SOURCE_DIR)/gcc-02-patch-17-getthreadid-alternative.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/0018-mcf-sjlj-avoid-infinite-recursion.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-19-freport-bug.done: | $(SOURCE_DIR)/gcc-02-patch-18-mcf-sjlj-infinite-recursion.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/0019-Fix-freport-bug-for-Windows.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-20-sanitizer-win64.done: | $(SOURCE_DIR)/gcc-02-patch-19-freport-bug.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/0020-Enable-sanitizer-support-on-Windows-x86_64.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-21-pecoff.done: | $(SOURCE_DIR)/gcc-02-patch-20-sanitizer-win64.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/0021-Use-pecoff-format-on-Windows.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-22-mmap-win.done: | $(SOURCE_DIR)/gcc-02-patch-21-pecoff.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/0022-Enable-mmap-reader-for-libbacktrace-on-Windows.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-23-disable-interceptors.done: | $(SOURCE_DIR)/gcc-02-patch-22-mmap-win.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/0023-Disable-some-interceptors-on-Windows-gcc-builds.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-24-colored-output-win.done: | $(SOURCE_DIR)/gcc-02-patch-23-disable-interceptors.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/0024-Enable-colored-output-on-Windows.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-25-dynamic-shadow-offset.done: | $(SOURCE_DIR)/gcc-02-patch-24-colored-output-win.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/0025-Implement-dynamic-shadow-offset-for-address-sanitize.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-26-EnumProcessModules-win7.done: | $(SOURCE_DIR)/gcc-02-patch-25-dynamic-shadow-offset.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/0026-Fix-EnumProcessModules-for-Win7.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-27-remove-futex-calls.done: | $(SOURCE_DIR)/gcc-02-patch-26-EnumProcessModules-win7.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/0027-Remove-futex-calls-not-available-on-Win7.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-28-colored-output-win7.done: | $(SOURCE_DIR)/gcc-02-patch-27-remove-futex-calls.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/0028-Enable-colored-output-on-Windows-7.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-29-fix-unsupported-flags.done: | $(SOURCE_DIR)/gcc-02-patch-28-colored-output-win7.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/0029-Fix-checks-for-unsupported-flags.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-30-psapi-win7.done: | $(SOURCE_DIR)/gcc-02-patch-29-fix-unsupported-flags.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/0030-Use-psapi.dll-on-Win7.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-31-sanitizer-win32.done: | $(SOURCE_DIR)/gcc-02-patch-30-psapi-win7.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/0031-Enable-sanitizer-support-on-Windows-x86.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-32-sanitizer-winxp.done: | $(SOURCE_DIR)/gcc-02-patch-31-sanitizer-win32.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/0032-Fix-sanitizers-for-WinXP.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-33-intercept-_strdup.done: | $(SOURCE_DIR)/gcc-02-patch-32-sanitizer-winxp.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/0033-Intercept-_strdup-on-Windows-gcc-builds.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-34-libubsan-lstdcxx.done: | $(SOURCE_DIR)/gcc-02-patch-33-intercept-_strdup.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/0034-Add-lstdc-when-linking-libubsan.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-35-link-lasan_dll_thunk.done: | $(SOURCE_DIR)/gcc-02-patch-34-libubsan-lstdcxx.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/0035-Link-lasan_dll_thunk-instead-of-lasan-into-shared-ta.patch
	@touch $@

$(SOURCE_DIR)/gcc-02-patch-36-link-lubsan_dll_thunk.done: | $(SOURCE_DIR)/gcc-02-patch-35-link-lasan_dll_thunk.done
	patch -d $(SOURCE_DIR)/$(GCC_SRC_DIR) -p1 <patches/gcc/0036-Link-lubsan_dll_thunk-instead-of-lubsan-into-shared-.patch
	@touch $@

$(BUILD_DIR)/gcc-03-configure.done: | $(BUILD_DIR)/binutils-07-licenses.done $(BUILD_DIR)/mingw-w64-05-headers-make-install.done $(SOURCE_DIR)/gcc-02-patch-36-link-lubsan_dll_thunk.done
	@mkdir -p $(BUILD_DIR)/gcc $(GCC_DIR)/mingw/include
	$(BINUTILS_PATH) cd $(BUILD_DIR)/gcc && $(GCC_CONF)
	@touch $@

$(BUILD_DIR)/gcc-04-make-gcc.done: | $(BUILD_DIR)/gcc-03-configure.done
	$(BINUTILS_PATH) $(MAKE) -C $(BUILD_DIR)/gcc all-gcc $(WINDRES_OVERRIDE)
	@touch $@

$(BUILD_DIR)/gcc-05-make-install-gcc.done: | $(BUILD_DIR)/gcc-04-make-gcc.done
	$(BINUTILS_PATH) $(MAKE) -C $(BUILD_DIR)/gcc install-strip-gcc
	@touch $@


# mingw-w64 crt

$(BUILD_DIR)/mingw-w64-06-crt-configure.done: | $(BUILD_DIR)/binutils-07-licenses.done $(BUILD_DIR)/gcc-05-make-install-gcc.done $(BUILD_DIR)/mingw-w64-05-headers-make-install.done
	@mkdir -p $(BUILD_DIR)/mingw-w64-crt
	$(GCC_PATH) cd $(BUILD_DIR)/mingw-w64-crt && $(MINGW_W64_CRT_CONF)
	@touch $@

$(BUILD_DIR)/mingw-w64-07-crt-make.done: | $(BUILD_DIR)/mingw-w64-06-crt-configure.done
	$(GCC_PATH) $(MAKE) -C $(BUILD_DIR)/mingw-w64-crt
	@touch $@

$(BUILD_DIR)/mingw-w64-08-crt-make-install.done: | $(BUILD_DIR)/mingw-w64-07-crt-make.done
	$(GCC_PATH) $(MAKE) -C $(BUILD_DIR)/mingw-w64-crt install
	@touch $@


# mcfgthread

$(SOURCE_DIR)/mcfgthread-01-extract.done: | pkg/$(MCFGTHREAD_FILE) $(SOURCE_DIR)/mingw-w64-01-extract.done
	tar -C $(SOURCE_DIR) -xzf pkg/$(MCFGTHREAD_FILE)
	@touch $@

$(SOURCE_DIR)/mcfgthread-02-patch-01-allow-XP.done: | $(SOURCE_DIR)/mcfgthread-01-extract.done
	patch -d $(SOURCE_DIR)/$(MCFGTHREAD_SRC_DIR) -p1 <patches/mcfgthread/0001-Remove-error-if-compiling-below-Win7.patch
	@touch $@

$(SOURCE_DIR)/mcfgthread-02-patch-02-BaseGetNamedObjectDirectory.done: | $(SOURCE_DIR)/mcfgthread-02-patch-01-allow-XP.done
	patch -d $(SOURCE_DIR)/$(MCFGTHREAD_SRC_DIR) -p1 <patches/mcfgthread/0002-WinXP-alternative-for-BaseGetNamedObjectDirectory.patch
	@touch $@

$(SOURCE_DIR)/mcfgthread-02-patch-03-GetTickCount64.done: | $(SOURCE_DIR)/mcfgthread-02-patch-02-BaseGetNamedObjectDirectory.done
	patch -d $(SOURCE_DIR)/$(MCFGTHREAD_SRC_DIR) -p1 <patches/mcfgthread/0003-WinXP-alternative-for-GetTickCount64.patch
	@touch $@

$(SOURCE_DIR)/mcfgthread-02-patch-04-NtWaitForKeyedEvent.done: | $(SOURCE_DIR)/mcfgthread-02-patch-03-GetTickCount64.done
	patch -d $(SOURCE_DIR)/$(MCFGTHREAD_SRC_DIR) -p1 <patches/mcfgthread/0004-NtWaitForKeyedEvent-on-WinXP-needs-an-explicit-keyed.patch
	@touch $@

$(SOURCE_DIR)/mcfgthread-02-patch-05-configure-no-executable.done: | $(SOURCE_DIR)/mcfgthread-02-patch-04-NtWaitForKeyedEvent.done
	patch -d $(SOURCE_DIR)/$(MCFGTHREAD_SRC_DIR) -p1 <patches/mcfgthread/0005-Disable-test-if-executable-creation-works-in-configu.patch
	@touch $@

$(SOURCE_DIR)/mcfgthread-02-patch-06-last-error-TLS.done: | $(SOURCE_DIR)/mcfgthread-02-patch-05-configure-no-executable.done
	patch -d $(SOURCE_DIR)/$(MCFGTHREAD_SRC_DIR) -p1 <patches/mcfgthread/0006-Save-and-restore-last-error-code-for-TLS-calls.patch
	@touch $@

$(SOURCE_DIR)/mcfgthread-03-autoreconf.done: | $(SOURCE_DIR)/mcfgthread-02-patch-06-last-error-TLS.done
	cd $(SOURCE_DIR)/$(MCFGTHREAD_SRC_DIR); autoreconf -i
	@touch $@

$(BUILD_DIR)/mcfgthread-04-configure.done: | $(BUILD_DIR)/binutils-07-licenses.done $(BUILD_DIR)/gcc-05-make-install-gcc.done $(BUILD_DIR)/mingw-w64-05-headers-make-install.done $(BUILD_DIR)/mingw-w64-08-crt-make-install.done $(SOURCE_DIR)/mcfgthread-03-autoreconf.done
	@mkdir -p $(BUILD_DIR)/mcfgthread
	$(GCC_PATH) cd $(BUILD_DIR)/mcfgthread && $(MCFGTHREAD_CONF)
	@touch $@

$(BUILD_DIR)/mcfgthread-05-make.done: | $(BUILD_DIR)/mcfgthread-04-configure.done
	$(GCC_PATH) $(MAKE) -C $(BUILD_DIR)/mcfgthread
	@touch $@

$(BUILD_DIR)/mcfgthread-06-make-install.done: | $(BUILD_DIR)/mcfgthread-05-make.done
	$(GCC_PATH) $(MAKE) -C $(BUILD_DIR)/mcfgthread install
	@touch $@


# gcc

$(BUILD_DIR)/gcc-06-make.done: | $(BUILD_DIR)/binutils-07-licenses.done $(BUILD_DIR)/mingw-w64-05-headers-make-install.done $(BUILD_DIR)/mingw-w64-08-crt-make-install.done $(BUILD_DIR)/gcc-05-make-install-gcc.done $(BUILD_DIR)/mcfgthread-06-make-install.done
	$(BINUTILS_PATH) $(MAKE) -C $(BUILD_DIR)/gcc
	@touch $@

$(BUILD_DIR)/gcc-07-make-install.done: | $(BUILD_DIR)/gcc-06-make.done
	$(BINUTILS_PATH) $(MAKE) -C $(BUILD_DIR)/gcc installdirs install-strip-host install-target
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
	cp -f $(GCC_DIR)/mingw/libexec/gcc/$(MYTARGET)/$(GCC_VER)/liblto_plugin.dll $(GCC_DIR)/mingw/lib/bfd-plugins/
	@touch $@

$(BUILD_DIR)/gcc-10-licenses.done: | $(BUILD_DIR)/gcc-09-lto-plugin.done
	@mkdir -p $(GCC_DIR)/mingw/share/licenses/mingw-w64
	cp -p $(SOURCE_DIR_ABS)/$(MINGW_W64_SRC_DIR)/COPYING.MinGW-w64/COPYING.MinGW-w64.txt $(GCC_DIR)/mingw/share/licenses/mingw-w64/
	cp -p $(SOURCE_DIR_ABS)/$(MINGW_W64_SRC_DIR)/COPYING.MinGW-w64-runtime/COPYING.MinGW-w64-runtime.txt $(GCC_DIR)/mingw/share/licenses/mingw-w64/
	@mkdir -p $(GCC_DIR)/mingw/share/licenses/mcfgthread
	cp -p $(SOURCE_DIR_ABS)/$(MCFGTHREAD_SRC_DIR)/LICENSE.TXT $(GCC_DIR)/mingw/share/licenses/mcfgthread/
	@mkdir -p $(GCC_DIR)/mingw/share/licenses/gcc
	cp -p $(SOURCE_DIR_ABS)/$(GCC_SRC_DIR)/COPYING3 $(GCC_DIR)/mingw/share/licenses/gcc/
	cp -p $(SOURCE_DIR_ABS)/$(GCC_SRC_DIR)/COPYING.RUNTIME $(GCC_DIR)/mingw/share/licenses/gcc/
	@mkdir -p $(GCC_DIR)/mingw/share/licenses/gmp
	cp -p $(SOURCE_DIR_ABS)/$(GCC_SRC_DIR)/gmp/COPYINGv3 $(GCC_DIR)/mingw/share/licenses/gmp/
	@mkdir -p $(GCC_DIR)/mingw/share/licenses/mpfr
	cp -p $(SOURCE_DIR_ABS)/$(GCC_SRC_DIR)/mpfr/COPYING.LESSER $(GCC_DIR)/mingw/share/licenses/mpfr/
	@mkdir -p $(GCC_DIR)/mingw/share/licenses/mpc
	cp -p $(SOURCE_DIR_ABS)/$(GCC_SRC_DIR)/mpc/COPYING.LESSER $(GCC_DIR)/mingw/share/licenses/mpc/
	@mkdir -p $(GCC_DIR)/mingw/share/licenses/isl
	cp -p $(SOURCE_DIR_ABS)/$(GCC_SRC_DIR)/isl/LICENSE $(GCC_DIR)/mingw/share/licenses/isl/
	@touch $@


extract-all: | \
  $(SOURCE_DIR)/binutils-01-extract.done \
  $(SOURCE_DIR)/mingw-w64-01-extract.done \
  $(SOURCE_DIR)/mcfgthread-01-extract.done \
  $(SOURCE_DIR)/gcc-01-extract-01-gcc.done \
  $(SOURCE_DIR)/gcc-01-extract-02-gmp.done \
  $(SOURCE_DIR)/gcc-01-extract-03-mpfr.done \
  $(SOURCE_DIR)/gcc-01-extract-04-mpc.done \
  $(SOURCE_DIR)/gcc-01-extract-05-isl.done \


patch-all: | \
  $(SOURCE_DIR)/binutils-02-patch-04-objcopy-large-address-aware.done \
  $(SOURCE_DIR)/mingw-w64-02-patch-09-def.in-symbols.done \
  $(SOURCE_DIR)/gcc-02-patch-36-link-lubsan_dll_thunk.done \
  $(SOURCE_DIR)/mcfgthread-02-patch-06-last-error-TLS.done \


build-binutils: | $(BUILD_DIR)/binutils-07-licenses.done
build-mingw-w64-headers: | $(BUILD_DIR)/mingw-w64-05-headers-make-install.done
build-gcc: | $(BUILD_DIR)/gcc-05-make-install-gcc.done
build-mcfgthread: | $(BUILD_DIR)/mcfgthread-06-make-install.done
build-mingw-w64-crt: | $(BUILD_DIR)/mingw-w64-08-crt-make-install.done
build-gcc-full: | $(BUILD_DIR)/gcc-10-licenses.done


binutils$(BUILD_BITS).7z: | build-binutils
	@rm -f $@
	cd $(BINUTILS_DIR) && 7z a -mx=9 ../$@ *

gcc$(BUILD_BITS).7z: | build-gcc-full
	@rm -f $@
	cd $(GCC_DIR)/mingw && 7z a -mx=9 ../../$@ *

gcc-$(GCC_VER)-$(MYPKG)-$(BUILD_ARCH).7z: | build-gcc-full
	@rm -f $@
	cd $(BINUTILS_DIR) && 7z a -mx=9 ../$@ *
	cd $(GCC_DIR)/mingw && 7z a -mx=9 ../../$@ *


package-binutils: binutils$(BUILD_BITS).7z
package-gcc: gcc$(BUILD_BITS).7z
package-all: gcc-$(GCC_VER)-$(MYPKG)-$(BUILD_ARCH).7z

packages: package-binutils
packages: package-gcc
packages: package-all


info:
	@echo -e "\r"
	@echo -e "$(BINUTILS_FILE)\r"
	@echo -e "$(MINGW_W64_FILE)\r"
	@echo -e "$(GCC_FILE)\r"
	@echo -e "$(GMP_FILE)\r"
	@echo -e "$(MPFR_FILE)\r"
	@echo -e "$(MPC_FILE)\r"
	@echo -e "$(ISL_FILE)\r"
