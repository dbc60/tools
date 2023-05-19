@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION ENABLEEXTENSIONS

:: See LICENSE.txt for copyright and licensing information about this file.

SET PROJECT_NAME="Hello World"
CALL tools\setup.cmd %*

:: Build the project
IF %build% EQU 1 (
    IF %verbose% EQU 1 (
        ECHO.
        ECHO Build !PROJECT_NAME!
    )
    cl %CommonCompilerFlagsFinal% /I%DIR_INCLUDE% src\main.c /Fo:%DIR_OUT_OBJ% /Fd:%DIR_OUT_BIN%\main.pdb /Fe:%DIR_OUT_BIN%\main.exe /link %CommonLinkerFlagsFinal% /ENTRY:mainCRTStartup

    REM copy the built program to the root folder for convenience
    if exist %DIR_OUT_BIN%\main.exe (
        copy /B /Y %DIR_OUT_BIN%\main.exe .\
    )
)
ENDLOCAL
