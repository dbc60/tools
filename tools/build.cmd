@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION ENABLEEXTENSIONS

:: See LICENSE.txt for copyright and licensing information about this file.

SET PROJECT_NAME="Hello"
CALL %~dp0setup.cmd %*

:: Build the project
IF %build% EQU 1 (
    IF %verbose% EQU 1 (
        ECHO.
        ECHO Build Hello
    )
    cl %CommonCompilerFlagsFinal% ^
    /I%DIR_INCLUDE% ^
    !DIR_REPO!\src\hello.c  /Fo:%DIR_OUT_OBJ%\ ^
    /Fd:%DIR_OUT_BIN%\hello.pdb /Fe:%DIR_OUT_BIN%\hello.exe /link ^
    %CommonLinkerFlagsFinal% /ENTRY:mainCRTStartup
)
ENDLOCAL
