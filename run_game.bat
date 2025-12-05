@echo off

:: Enhanced Python detection script
:: Try multiple possible Python commands
set PYTHON_CMD=

:: Method 1: Try standard python command
call :check_python_command "python"
if defined PYTHON_CMD goto check_python_version

:: Method 2: Try python3 command
call :check_python_command "python3"
if defined PYTHON_CMD goto check_python_version

:: Method 3: Try py command (Windows recommended Python launcher)
call :check_python_command "py"
if defined PYTHON_CMD goto check_python_version

:: If all methods fail
:python_not_found
echo Error: Python is not detected or not added to system PATH.
echo Please confirm:
echo 1. Python 3.6 or higher is installed
echo 2. "Add Python to PATH" was selected during installation
echo 3. Or manually add Python installation directory to system PATH
echo 4. Or try running this script as Administrator
pause
exit /b 1

:: Check if a specific Python command is available
:check_python_command
    %~1 --version >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        set PYTHON_CMD=%~1
        exit /b 0
    )
    exit /b 1

:: Check if Python version meets requirements (>=3.6)
:check_python_version
    echo Detected Python command: %PYTHON_CMD%
    for /f "tokens=2" %%a in ('%PYTHON_CMD% --version 2^>^&1') do set PYTHON_VERSION=%%a
    echo Python version: %PYTHON_VERSION%
    
    :: Extract major and minor version numbers
    for /f "tokens=1,2 delims=." %%a in ("%PYTHON_VERSION%") do (
        set PYTHON_MAJOR=%%a
        set PYTHON_MINOR=%%b
    )
    
    :: Check if version meets requirements
    if %PYTHON_MAJOR% LSS 3 goto version_too_low
    if %PYTHON_MAJOR% EQU 3 if %PYTHON_MINOR% LSS 6 goto version_too_low
    
    echo Python version meets requirements (>=3.6)
    goto check_pip
    
    :version_too_low
echo Error: Python version too low (%PYTHON_VERSION%)
echo Please install Python 3.6 or higher.
pause
exit /b 1

:: Check if pip is available
:check_pip
    :: Method 1: Try using Python -m pip
    %PYTHON_CMD% -m pip --version >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        set PIP_CMD=%PYTHON_CMD% -m pip
        echo pip is available (via -m pip)
        goto install_dependencies
    )
    
    :: Method 2: Try direct pip command
    pip --version >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        set PIP_CMD=pip
        echo pip is available (direct command)
        goto install_dependencies
    )
    
    echo Error: pip is not available.
echo Please try installing pip manually or reinstall Python with "Install pip" option.
pause
exit /b 1

:: Install dependencies
:install_dependencies
echo Installing required dependencies...
%PIP_CMD% install pywebview --quiet
if %ERRORLEVEL% NEQ 0 (
    echo Error: Failed to install pywebview.
echo Please try installing manually: %PYTHON_CMD% -m pip install pywebview
pause
exit /b 1
)

:: Start the game
:start_game
echo Starting 4Ascend Game...
%PYTHON_CMD% game_launcher.py

:: Cleanup after game exit
if %ERRORLEVEL% NEQ 0 (
    echo Game exited with an error.
pause
exit /b 1
)

exit /b 0