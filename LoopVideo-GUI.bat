@echo off
REM Video Loop Creator - GUI Launcher
REM This batch file launches the Video Loop Creator in GUI mode

title Video Loop Creator - GUI Mode

REM Change to the script directory
cd /d "%~dp0"

REM Launch the PowerShell script in GUI mode
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "loopvideo.ps1" -GUI

REM If there's an error, pause to show it
if errorlevel 1 (
    echo.
    echo An error occurred while launching the Video Loop Creator.
    echo Please ensure PowerShell and FFmpeg are properly installed.
    echo.
    pause
)
