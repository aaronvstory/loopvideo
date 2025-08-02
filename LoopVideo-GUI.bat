@echo off
REM LoopVideo - GUI Launcher
REM Masterfully created by @dedkamaroz
REM This batch file launches the Video Loop Creator in GUI mode

REM Change to the script directory
cd /d "%~dp0"

REM Launch the PowerShell script in GUI mode (hidden window, no console output)
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -NoProfile -Command "& '%~dp0loopvideo.ps1' -GUI -DisableDialogues"

REM Exit immediately without showing console
exit /b
