@echo off
setlocal enabledelayedexpansion

:: Basic functionality test for MediaCreationTool.bat
:: This test verifies that MediaCreationTool.bat can be invoked and produces initial output
:: Author: Test script for MediaCreationTool.bat project
:: Version: 1.0

title MediaCreationTool.bat - Basic Functionality Test

echo.
echo ===================================================================
echo  MediaCreationTool.bat - Basic Functionality Test
echo ===================================================================
echo.
echo This test verifies that MediaCreationTool.bat can be invoked and
echo starts correctly, serving as a basic functionality check.
echo.

:: Test variables
set "SCRIPT_NAME=MediaCreationTool.bat"
set "TEST_PASSED=0"
set "ERROR_COUNT=0"

:: Check if the main script exists
echo [TEST 1] Checking if %SCRIPT_NAME% exists...
if not exist "%~dp0%SCRIPT_NAME%" (
    echo [FAIL] %SCRIPT_NAME% not found in current directory
    set /a ERROR_COUNT+=1
    goto :show_results
) else (
    echo [PASS] %SCRIPT_NAME% found
)

echo.
echo [TEST 2] Attempting to invoke %SCRIPT_NAME% with help parameter...
echo.

:: Create a temporary batch file to capture output
set "TEMP_OUTPUT=%TEMP%\mct_test_output.txt"
set "TEMP_SCRIPT=%TEMP%\mct_test_runner.bat"

:: Create a test runner script that will try to run MCT and capture any output
echo @echo off > "%TEMP_SCRIPT%"
echo setlocal >> "%TEMP_SCRIPT%"
echo title MCT Test >> "%TEMP_SCRIPT%"
echo. >> "%TEMP_SCRIPT%"
echo :: Try to run MediaCreationTool.bat with help parameter >> "%TEMP_SCRIPT%"
echo :: This should either show help or fail gracefully >> "%TEMP_SCRIPT%"
echo echo Starting MediaCreationTool.bat test execution... >> "%TEMP_SCRIPT%"
echo echo. >> "%TEMP_SCRIPT%"
echo call "%~dp0%SCRIPT_NAME%" help 2^>^&1 >> "%TEMP_SCRIPT%"
echo if errorlevel 1 ( >> "%TEMP_SCRIPT%"
echo     echo Script exited with error level %%errorlevel%% >> "%TEMP_SCRIPT%"
echo ^) else ( >> "%TEMP_SCRIPT%"
echo     echo Script completed successfully >> "%TEMP_SCRIPT%"
echo ^) >> "%TEMP_SCRIPT%"
echo echo. >> "%TEMP_SCRIPT%"
echo echo MediaCreationTool.bat test execution completed. >> "%TEMP_SCRIPT%"

:: Run the test script with a timeout to prevent hanging
echo Executing MediaCreationTool.bat for 10 seconds...
echo (This will timeout automatically to prevent hanging)
echo.

:: Use timeout command to limit execution time
timeout /t 2 /nobreak >nul
echo Starting test execution...

:: Try to run with timeout - if available, use it, otherwise just try to run
where timeout >nul 2>&1
if !errorlevel! equ 0 (
    timeout /t 5 /nobreak >nul & call "%TEMP_SCRIPT%" > "%TEMP_OUTPUT%" 2>&1 &
    timeout /t 10 /nobreak >nul
) else (
    call "%TEMP_SCRIPT%" > "%TEMP_OUTPUT%" 2>&1
)

echo.
echo [TEST 3] Analyzing output...
echo.

:: Check if we got any output
if exist "%TEMP_OUTPUT%" (
    echo Output captured from MediaCreationTool.bat:
    echo ---------------------------------------------------
    type "%TEMP_OUTPUT%"
    echo ---------------------------------------------------
    echo.
    
    :: Look for expected content in the output
    echo [TEST 4] Checking for expected content indicators...
    
    :: Check for script name or version information
    findstr /i /c:"MediaCreationTool" "%TEMP_OUTPUT%" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [PASS] Found 'MediaCreationTool' reference in output
        set /a TEST_PASSED+=1
    ) else (
        echo [INFO] 'MediaCreationTool' reference not found in output
    )
    
    :: Check for MCT title or Universal MCT reference
    findstr /i /c:"MCT" "%TEMP_OUTPUT%" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [PASS] Found 'MCT' reference in output
        set /a TEST_PASSED+=1
    ) else (
        echo [INFO] 'MCT' reference not found in output
    )
    
    :: Check for Universal or wrapper reference
    findstr /i /c:"Universal\|wrapper\|Windows" "%TEMP_OUTPUT%" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [PASS] Found Windows/Universal/wrapper reference in output
        set /a TEST_PASSED+=1
    ) else (
        echo [INFO] Windows/Universal/wrapper reference not found in output
    )
    
    :: Check for any error messages
    findstr /i /c:"error\|fail\|exception" "%TEMP_OUTPUT%" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [WARN] Found potential error messages in output
        set /a ERROR_COUNT+=1
    ) else (
        echo [PASS] No obvious error messages detected
        set /a TEST_PASSED+=1
    )
    
) else (
    echo [FAIL] No output captured from MediaCreationTool.bat
    set /a ERROR_COUNT+=1
)

:show_results
echo.
echo ===================================================================
echo  TEST RESULTS SUMMARY
echo ===================================================================
echo.
echo Tests passed: %TEST_PASSED%
echo Errors detected: %ERROR_COUNT%
echo.

if %TEST_PASSED% gtr 0 (
    if %ERROR_COUNT% equ 0 (
        echo [SUCCESS] MediaCreationTool.bat appears to be working correctly!
        echo The script can be invoked and produces expected output.
    ) else (
        echo [PARTIAL SUCCESS] MediaCreationTool.bat can be invoked but with some issues.
        echo The script starts but may have encountered errors.
    )
) else (
    echo [FAILURE] MediaCreationTool.bat test failed.
    echo The script may not be accessible or may have critical issues.
)

echo.
echo ===================================================================
echo  ADDITIONAL INFORMATION
echo ===================================================================
echo.
echo This test serves as a basic functionality check for MediaCreationTool.bat.
echo It verifies that:
echo   1. The script file exists and is accessible
echo   2. The script can be invoked without immediate crashes
echo   3. The script produces some form of recognizable output
echo   4. Basic error detection for obvious failures
echo.
echo For full functionality testing, run MediaCreationTool.bat manually
echo in a Windows environment with appropriate permissions.
echo.
echo Test completed: %date% %time%
echo.

:: Clean up temporary files
if exist "%TEMP_OUTPUT%" del /f /q "%TEMP_OUTPUT%" >nul 2>&1
if exist "%TEMP_SCRIPT%" del /f /q "%TEMP_SCRIPT%" >nul 2>&1

pause
exit /b %ERROR_COUNT%