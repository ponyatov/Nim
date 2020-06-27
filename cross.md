# `-cross` branch Nim variant

This `-cross` branch of the Nim translator contains special tunes for the
generic `nim` version targets on making it *cross-compiler in the first*.

see this [cross.md] for more info


## full POSIX compatibility

For multiplatform programming and the wide use of the Nim language, it is
required to follow all OpenSource community conventions, including full POSIX
compatibility, coding and tools habits, cross-compiling ability to any arbitrary
target system, and support most used toolchains matrix (CPU/OS/libs/toolchains).

* POSIX.1-2008 / IEEE Std 1003.1-2017
  * [`c99` - compile standard C programs](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/c99.html)
  * [`make` - maintain, update, and regenerate groups of files](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/make.html)


## GNU toolchain

GNU toolchain (gcc/g++/...) is the most mature free compiler package which
targets most known hardware architectures including rarely used and ancient
ones. The most frequent use case besides desktop programming is compiling for a
wide variety of microcontrollers such as ATmega (Arduino), Cortex-M (STM32), and
MSP430 series.

For Windows programming, we have a powerful, compact, and free MinGW package
that integrates all GNU toolchain, base libraries, and POSIX tools both for
Windows self-hosted and cross-compiling from Linux workstation. As Windows still
stays the most popular OS, especially in the case of legacy systems (*), we
should avoid Python-dev team error of a legacy lock on M$ compiler, and use
MinGW as the main backend (cross-)compiler.
<br>(*) old computers, legacy embedded systems (industrial and lab equipment)


## GNU make

`make` is the most portable build tool, and available on any `$HOST` operating
system:

|||
|-|-|
|   Linux:|`sudo apt install make`|
| Windows:|MinGW, nmake|
|   MacOS:|`brew install homebrew/core/make`|

See core [Makefile](https://github.com/ponyatov/Nim/blob/ponyatov-cross/Makefile)
as a sample of build scripts targeted on cross-compiling, with most snippets
commented.

### some notes on `make` portability

todo: write GNU-compatible `nimake` clone in pure Nim

* [`make` tool official specification](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/make.html)
* https://nullprogram.com/blog/2017/08/20/

### MinGW: Windows cross-compiling

Compiling for Windows can be done on-host, but the preferred way for many
developers is the cross-compiling from the Linux workstation/virtual machine.
Both ways require MinGW package to be installed:

* [MinGW/MSYS](http://www.mingw.org/) for on-host install (win32, for older systems)
* [mingw-w64/msys2](http://mingw-w64.org/) 32/64-bit compiling support
* Linux host: `make Linux-install-mingw`
* adaptive install thru `make install-mingw`

For project cross-builds `make` must be run with predefined/overridden `$TARGET`
variable in the environment, or in a single command line:

```sh
~$ TARGET=i686-w64-mingw make all tests
```

The `win64`/`mingw64` target is still ignored in the `-cross` branch as 32-bit
compiling has much more interest in case of software (re)write in Nim for legacy
systems and it stays compatible with any modern Windows (besides some rare case
such as drivers and plugins development).

### `install` targets

```make
install: $(OS)_install $(TARGET)_$(OS)_install
update: $(OS)_update $(TARGET)_$(OS)_update
```

* `$(OS)_install` software for host `$OS`
  * `Linux_*install` uses apt (Debian, Ubuntu)
* `$(TARGET)_$(OS)_install` software for `$TARGET` runs runs under host `$OS`
* `install-mingw` special fastcall for MinGW install


## Clang/LLVM

Clang/LLVM is the most perspective backend compiler for the replacement of the
ancient GNU compiler toolchain. In the last dozen years is shows large growth in
number of hardware supported, optimization algorithms, popularity, and number of
developers targets it as a backend part of new compilers design.

* [The LLVM Compiler Infrastructure](https://llvm.org/)
* [Clang: a C language family frontend for LLVM](https://clang.llvm.org/)

Many known vendors targets on the LLVM toolchain for commercial use and mainline
development, so we can't ignore this trend to made Nim compatible with modern
platforms:

* Apple
  * [LLVM Compiler Overview](https://developer.apple.com/library/archive/documentation/CompilerTools/Conceptual/LLVMCompilerOverview/index.html)
* Sony
  * [PlayStation 4 SDK](https://llvm.org/devmtg/2013-11/slides/Robinson-PS4Toolchain.pdf) (AMD x86-64 Jaguar / Radeon GPU)
  * `znver1` hardware target (custom AMD Ryzen 7)
    * [Sony Is Working On AMD Ryzen LLVM Compiler Improvements - Possibly For The PlayStation 5](https://www.phoronix.com/scan.php?page=news_item&px=Sony-LLVM-Ryzen-Improvements)
* Microsoft
  * https://github.com/microsoft/llvm

While Nim translation to low-level LLVM IR code is not considered to be usable
for a mainline method of compiling, the C/C++ code generation must be fully
compatible with the `Clang` backend compiler, including intrinsic support and
vectorizer hacks.


## `unikernel` for scalable clouds and cluster computing

* https://en.wikipedia.org/wiki/Unikernel
  * https://en.wikipedia.org/wiki/Rump_kernel
    * http://rumpkernel.org/

`single app, no kernel` libOS approach is good for cloud and clustering
distributed systems, which can expand on-demand under high load, and work under
virtualized environments (including Xen hypervisor), rented VDS servers, or
local experimental clusters (made of refurbished computers, or in a guest mode
under desktop OSes)

For unikernel development, Nim requires *cross-compiler mode for standalone
programs* (without OS kernel), bundled with the `newlib` libc, `FreeRTOS` for
light tasking, `LwIP`, and some other application-specific libraries.


## IoT & embedded systems

