@echo off
REM 🎬 LoopVideo - Epic GUI Launcher 🎬
REM 💎 Masterfully created by @dedkamaroz 💎
REM This batch file launches the LEGENDARY Video Loop Creator in GUI mode

title 🎬 LoopVideo by @dedkamaroz - GUI Mode 💎

REM Change to the script directory
cd /d "%~dp0"

REM Launch the PowerShell script in GUI mode
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "loopvideo.ps1" -GUI

REM If there's an error, pause to show it
if errorlevel 1 (
    echo.
    echo An error occurred while launching @dedkamaroz's EPIC Video Loop Creator.
    echo Please ensure PowerShell and FFmpeg are properly installed.
    echo Don't worry - the AMAZING @dedkamaroz has made setup.bat to help you!
    echo.
    pause
)
