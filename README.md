Custom Windows build of gcc with these features:
- produces by default executables running on WinXP (msvcrt)
- static runtime libraries
- [MCF](https://github.com/lhmouse/mcfgthread/) threads
- [AddressSanitizer](https://clang.llvm.org/docs/AddressSanitizer.html)
- [UndefinedBehaviorSanitizer](https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html)

Because the sanitizers on windows
[no longer support static linking](https://github.com/llvm/llvm-project/commit/246234ac70faa1e3281a2bb83dfc4dd206a7d59c),
the gcc-15/16 builds can't handle sanitized dlls (but linking everything into 1 executable still works).<br>
That might change in the future if I get shared linking of sanitizers working, but until then I suggest using the
[gcc-14.4](https://github.com/ssbssa/gcc/releases/tag/gcc-14.4-ssbssa-1) build if you need sanitized dlls.
