@echo off
title LoopVideo Setup
echo.
echo ==========================================
echo         LoopVideo Setup & Checker
echo ==========================================
echo.

:: Change to script directory
cd /d "%~dp0"

echo [1/4] Checking PowerShell...
powershell -Command "Write-Host 'PowerShell is available' -ForegroundColor Green" 2>nul
if errorlevel 1 (
    echo ERROR: PowerShell not found! Please install PowerShell.
    echo Download from: https://github.com/PowerShell/PowerShell/releases
    pause
    exit /b 1
)

echo [2/4] Checking FFmpeg...
ffmpeg -version >nul 2>&1
if errorlevel 1 (
    echo.
    echo WARNING: FFmpeg not found in PATH!
    echo.
    echo Please install FFmpeg:
    echo 1. Download from: https://ffmpeg.org/download.html
    echo 2. Extract to C:\ffmpeg
    echo 3. Add C:\ffmpeg\bin to your PATH
    echo 4. Restart this script
    echo.
    echo Would you like to continue anyway? The script will show installation instructions.
    choice /c YN /m "Continue"
    if errorlevel 2 exit /b 1
) else (
    echo FFmpeg is available
)

echo [3/4] Checking PowerShell Execution Policy...
powershell -Command "if ((Get-ExecutionPolicy) -eq 'Restricted') { Write-Host 'Execution Policy needs adjustment' -ForegroundColor Yellow } else { Write-Host 'Execution Policy is OK' -ForegroundColor Green }"

echo [4/4] Testing LoopVideo script...
if not exist "loopvideo.ps1" (
    echo ERROR: loopvideo.ps1 not found in current directory!
    pause
    exit /b 1
)

echo.
echo ==========================================
echo              Setup Complete!
echo ==========================================
echo.
echo Quick Start Options:
echo.
echo [1] Launch GUI Mode (Recommended)
echo [2] Command Line Help
echo [3] Test with sample video
echo [Q] Quit
echo.
choice /c 123Q /m "Choose an option"

if errorlevel 4 exit /b 0
if errorlevel 3 goto test
if errorlevel 2 goto help
if errorlevel 1 goto gui

:gui
echo.
echo Launching GUI mode...
powershell -ExecutionPolicy Bypass -File "loopvideo.ps1" -GUI
goto end

:help
echo.
echo Command Line Usage:
echo.
echo   Basic: powershell -ExecutionPolicy Bypass -File "loopvideo.ps1" -InputFile "video.mp4"
echo   Custom: powershell -ExecutionPolicy Bypass -File "loopvideo.ps1" -InputFile "video.mp4" -Quality "fast"
echo.
pause
goto end

:test
if exist "test.mp4" (
    echo.
    echo Testing with sample video...
    powershell -ExecutionPolicy Bypass -File "loopvideo.ps1" -InputFile "test.mp4"
) else (
    echo.
    echo Sample video not found. Please add a test.mp4 file to test.
    pause
)
goto end

:end
echo.
echo Setup script finished.
pause