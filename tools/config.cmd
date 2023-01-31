@echo off
SETLOCAL ENABLEDELAYEDEXPANSION ENABLEEXTENSIONS

:: See LICENSE.txt for copyright and licensing information about this file.

:: Added _UNICODE and UNICODE so I can use Unicode strings in structs and
:: whatnot.
::
:: Need user32.lib to link MessageBox(), which es used on branch DAY001
:: Need gdi32.lib to link PatBlt(), which es used on branch DAY002
:: 2015.01.25 (Day004) I added /FC to get full path names in diagnostics. It's
:: helpful when using Emacs to code and launch the debugger and executable

:: /GS- turn off security checks because that compile-time option relies on
:: the C runtime library, which we are not using.

:: /Gs[size] The number of bytes that local variables can occupy before
:: a stack probe is initiated. If the /Gs option is specified without a
:: size argument, it is the same as specifying /Gs0

:: /Gm- disable minimal rebuild. We want to build everything. It won't
:: take long.

:: /GR- disable C++ RTTI. We don't need runtime type information.

:: /EHsc enable C++ EH (no SEH exceptions) (/EHs),
:: and  extern "C" defaults to nothrow (/EHc). That is, the compiler assumes
:: that functions declared as extern "C" never throw a C++ exception.

:: /EHa- disable C++ Exception Handling, so we don't have stack unwind code.
:: Casey says we don't need it.


:: /W3 set warning level 3.
:: /W4 set warning level 4. It's better
:: /WX warnings are errors
:: /wd turns off a particular warning
::   /wd4201 - nonstandard extension used : nameless struct/union
::   /wd4100 - 'identifier' : unreferenced formal parameter (this happens a lot while developing code)
::   /wd4189 - 'identifier' : local variable is initialized but not referenced
::   /wd4127 - conditional expression is constant ("do {...} while (0)" in macros)

:: /FC use full pathnames in diagnostics

:: /Od - disable optimizations. The debug mode is good for development

:: /Oi Generate intrinsic functions. Replaces some function calls with
:: intrinsic or otherwise special forms of the function that help your
:: application run faster.

:: /GL whole program optimization. Use the /LTCG linker option to create the
:: output file. /ZI cannot be used with /GL.

:: /I<dir> add to include search path

:: /Fe:<file> name executable file

:: /D<name>{=|#}<text> define macro

:: /Zi enable debugging information
:: /Z7 enable debugging information

:: /link [linker options and libraries] The linker options are
:: documented here: https://msdn.microsoft.com/en-us/library/y0zzbyt4.aspx

:: /nodefaultlib t

:: Note that subsystem version number 5.1 only works with 32-bit builds.
:: The minimum subsystem version number for 64-bit buils is 5.2.
:: /subsystem:windows,5.1 - enable compatibility with Windows XP (5.1)

:: /LTCG link time code generation

:: /STACK:reserve[,commit] stack allocations. The /STACK option sets the size
:: of the stack in bytes. Use this option only when you build an .exe file.

:: DEFINITIONS
::   _UNICODE           - 16-bit wide characters
::   UNICODE            - 16-bit wide characters
::   BUILD_INTERNAL     - 0 = build for public release,
::                        1 = build for developers only
::   BUILD_SLOW         - 0 = No slow code (like assertion checks) allowed!,
::                        1 = Slow code welcome
::   __ISO_C_VISIBLE    - the version of C we are targeting for the math library.
::                        1995 = C95, 1999 = C99, 2011 = C11.

:: BUILD PROPERTIES
:: It's possible to set build properties from the command line using the /p:<Property>=<value>
:: command-line option. For example, to set TargetPlatformVersion to 10.0.10240.0, you would
:: add "/p:TargetPlatformVersion=10.0.10240.0" and possibly
:: "/p:WindowsTargetPlatformVersion=10.0.10240.0". Note that the TargetPlatformVersion setting
:: is optional and allows you to specify the kit version to build with. The default is to use
:: the latest kit.

:: Building Software Using the Universal CRT (VS2015)
:: Use the UniversalCRT_IncludePath property to find the Universal CRT SDK header files.
:: Use one of the following properties to find the linker/library files:
::    UniversalCRT_LibraryPath_x86
::    UniversalCRT_LibraryPath_x64
::    UniversalCRT_LibraryPath_arm

:: Common compiler flags
SET CommonCompilerFlags=/nologo /Zc:wchar_t /Zc:forScope /Zc:inline /Gd /Gm- ^
    /GR- /EHa- /EHsc /Oi /WX /W4 /wd4201 /wd4100 /volatile:iso ^
    /wd4189 /wd4127 /wd4505 /FC /D _UNICODE /D UNICODE /D _WIN32 /D WIN32

::SET CStandardLibraryIncludeFlags=/I"%VSINSTALLDIR%SDK\ScopeCppSDK\SDK\include\ucrt"
::SET CMicrosoftIncludeFlags=/I"%VSINSTALLDIR%SDK\ScopeCppSDK\SDK\include\um" ^
::    /I"%VSINSTALLDIR%SDK\ScopeCppSDK\SDK\include\shared"
::SET CRuntimeIncludeFlags=/I"%VSINSTALLDIR%SDK\ScopeCppSDK\VC\include"

:: Debug and optimized compiler flags
SET CommonCompilerFlagsDEBUG=/MTd  /Zi /Od %CommonCompilerFlags%
SET CommonCompilerFlagsOPTIMIZE=/MT /Zo /O2 /Oi /favor:blend ^
    %CommonCompilerFlags%

:: Preprocessor definitions for a Library build
SET CommonCompilerFlagsBuildLIB=/D _LIB

:: Preprocessor definitions for a DLL build
SET CommonCompilerFlagsBuildDLL=/D _USRDLL /D _WINDLL

:: Choose either Debug or Optimized Compiler Flags
IF %release% EQU 1 (
    SET CommonCompilerFlagsFinal=%CommonCompilerFlagsOPTIMIZE%
) ELSE (
    SET CommonCompilerFlagsFinal=%CommonCompilerFlagsDEBUG%
)


:: Common linker flags
:: set CommonLinkerFlags=/incremental:no /opt:ref user32.lib gdi32.lib winmm.lib
SET CommonLinkerFlags=/nologo /incremental:no /MANIFESTUAC /incremental:no ^
    /opt:ref
SET CommonLinkerFlagsX64=/MACHINE:X64 %CommonLinkerFlags%
SET CommonLinkerFlagsX86=/MACHINE:X86 %CommonLinkerFlags%

:: Choose 32-bit or 64-bit build
if %x86% EQU 1 (
    SET CommonLinkerFlagsFinal=%CommonLinkerFlagsX86%
) else if %x64% EQU 1 (
    SET CommonLinkerFlagsFinal=%CommonLinkerFlagsX64%
) else (
    ECHO CONFIG.CMD ERROR: Unknown platform target "%PLATFORM%"
    GOTO :EOF
)

:: Visual Studio Librarian Options
if %debug% EQU 1 (
    SET CommonLibrarianFlags=/nologo
)

REM "LTCG" stands for link-time code generation.
if %release EQU 1 (
    SET CommonLibrarianFlags=/LTCG /nologo
)

if %trace% EQU 1 (
    ECHO CommonCompilerFlagsFinal = %CommonCompilerFlagsFinal%
    ECHO CommonLinkerFlagsFinal = %CommonLinkerFlagsFinal%
    ECHO CommonLibrarianFlags = %CommonLibrarianFlags%
)

:: It seems that the minimum subsystem is 5.02 for 64-bit Windows XP. Both "/subsystem:windows,5.1" and
:: /subsystem:windows,5.01" failed with linker warning "LNK4010: invalid subsystem version number 5.1"

:: 32-bit build
:: cl %CommonCompilerFlags% "%DIR_REPO%\src\win32_all.cpp" /link /subsystem:windows,5.02 %CommonLinkerFlagsFinal%

:: 64-bit build
:: set datetime=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
:: set datetime=%datetime: =0%
:: Optimization switches /O2 /Oi /fp:fast

ENDLOCAL & (
    SET "CommonCompilerFlagsFinal=%CommonCompilerFlagsFinal%"
    SET "CommonLinkerFlagsFinal=%CommonLinkerFlagsFinal%"
    SET "CommonLibrarianFlags=%CommonLibrarianFlags%"
)
