@echo off
setlocal

:: MediaCreationTool.bat GUI Launcher
:: This file launches the PowerShell GUI for MediaCreationTool.bat
:: Usage: Start-GUI.bat [-AutoSelectLatest | /AutoSelectLatest | --auto-latest]

title MediaCreationTool.bat GUI Launcher

echo Starting MediaCreationTool.bat GUI...
echo.

:: Check if PowerShell is available
powershell -Command "Get-Host" >nul 2>&1
if errorlevel 1 (
    echo ERROR: PowerShell is not available or not working properly.
    echo Please ensure PowerShell is installed and functioning.
    pause
    exit /b 1
)

:: Check if the GUI script exists
if not exist "%~dp0MediaCreationTool.GUI.ps1" (
    echo ERROR: MediaCreationTool.GUI.ps1 not found in the current directory.
    echo Please ensure both files are in the same folder.
    pause
    exit /b 1
)

:: Check if the main script exists
if not exist "%~dp0MediaCreationTool.bat" (
    echo ERROR: MediaCreationTool.bat not found in the current directory.
    echo Please ensure both files are in the same folder.
    pause
    exit /b 1
)

:: Launch the PowerShell GUI
echo Launching GUI interface...
powershell -ExecutionPolicy Bypass -File "%~dp0MediaCreationTool.GUI.ps1" %*

:: Check for errors
if errorlevel 1 (
    echo.
    echo WARNING: The GUI may have encountered an error.
    echo You can still use the original command-line version by running MediaCreationTool.bat directly.
    pause
)

exit /b 0