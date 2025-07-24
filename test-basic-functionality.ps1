# MediaCreationTool.bat - Basic Functionality Test (PowerShell Version)
# This test verifies that MediaCreationTool.bat can be invoked and produces initial output
# Author: Test script for MediaCreationTool.bat project
# Version: 1.0

param(
    [int]$TimeoutSeconds = 10,
    [switch]$Verbose
)

# Set up console
$Host.UI.RawUI.WindowTitle = "MediaCreationTool.bat - Basic Functionality Test (PowerShell)"

Write-Host ""
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host " MediaCreationTool.bat - Basic Functionality Test (PowerShell)" -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This test verifies that MediaCreationTool.bat can be invoked and" -ForegroundColor Gray
Write-Host "starts correctly, serving as a basic functionality check." -ForegroundColor Gray
Write-Host ""

# Test variables
$ScriptName = "MediaCreationTool.bat"
$TestsPassed = 0
$ErrorCount = 0
$ScriptPath = Join-Path $PSScriptRoot $ScriptName

# Function to write test results
function Write-TestResult {
    param(
        [string]$Status,
        [string]$Message
    )
    
    switch ($Status.ToUpper()) {
        "PASS" { Write-Host "[PASS] $Message" -ForegroundColor Green }
        "FAIL" { Write-Host "[FAIL] $Message" -ForegroundColor Red }
        "WARN" { Write-Host "[WARN] $Message" -ForegroundColor Yellow }
        "INFO" { Write-Host "[INFO] $Message" -ForegroundColor Cyan }
        default { Write-Host "[$Status] $Message" }
    }
}

# Test 1: Check if the main script exists
Write-Host "[TEST 1] Checking if $ScriptName exists..." -ForegroundColor Yellow
if (Test-Path $ScriptPath) {
    Write-TestResult "PASS" "$ScriptName found at: $ScriptPath"
    $TestsPassed++
} else {
    Write-TestResult "FAIL" "$ScriptName not found in current directory: $PSScriptRoot"
    $ErrorCount++
    # Continue with tests even if file doesn't exist for demonstration
}

Write-Host ""
Write-Host "[TEST 2] Attempting to read script content and verify structure..." -ForegroundColor Yellow

try {
    if (Test-Path $ScriptPath) {
        $scriptContent = Get-Content $ScriptPath -First 50 -ErrorAction Stop
        
        # Check for expected script markers
        $foundMarkers = @()
        
        if ($scriptContent -match "Universal MCT wrapper") {
            $foundMarkers += "Universal MCT wrapper"
            Write-TestResult "PASS" "Found 'Universal MCT wrapper' in script content"
            $TestsPassed++
        }
        
        if ($scriptContent -match "MediaCreationTool\.bat" -or $scriptContent -match "github\.com/AveYo") {
            $foundMarkers += "MediaCreationTool reference"
            Write-TestResult "PASS" "Found MediaCreationTool or repository reference"
            $TestsPassed++
        }
        
        if ($scriptContent -match "@echo off" -or $scriptContent -match "@goto") {
            $foundMarkers += "Batch script structure"
            Write-TestResult "PASS" "Valid batch script structure detected"
            $TestsPassed++
        }
        
        if ($foundMarkers.Count -eq 0) {
            Write-TestResult "WARN" "Script content doesn't match expected patterns"
            $ErrorCount++
        }
        
        Write-Host ""
        Write-Host "First few lines of the script:" -ForegroundColor Gray
        Write-Host "----------------------------------------" -ForegroundColor Gray
        $scriptContent | Select-Object -First 10 | ForEach-Object {
            Write-Host $_ -ForegroundColor DarkGray
        }
        Write-Host "----------------------------------------" -ForegroundColor Gray
        
    } else {
        Write-TestResult "FAIL" "Cannot read script content - file not accessible"
        $ErrorCount++
    }
} catch {
    Write-TestResult "FAIL" "Error reading script content: $($_.Exception.Message)"
    $ErrorCount++
}

Write-Host ""
Write-Host "[TEST 3] Testing script invocation (if on Windows)..." -ForegroundColor Yellow

$isWindowsOS = if ($PSVersionTable.PSVersion.Major -ge 6) { 
    try { 
        [System.Environment]::OSVersion.Platform -eq [System.PlatformID]::Win32NT
    } catch { 
        $env:OS -eq "Windows_NT" 
    }
} else { 
    $env:OS -eq "Windows_NT" 
}

if ($isWindowsOS) {
    try {
        # Try to invoke the script with help parameter using cmd
        $processInfo = New-Object System.Diagnostics.ProcessStartInfo
        $processInfo.FileName = "cmd.exe"
        $processInfo.Arguments = "/c `"$ScriptPath`" help"
        $processInfo.UseShellExecute = $false
        $processInfo.RedirectStandardOutput = $true
        $processInfo.RedirectStandardError = $true
        $processInfo.WorkingDirectory = $PSScriptRoot
        
        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $processInfo
        
        Write-Host "Attempting to run: cmd.exe /c `"$ScriptPath`" help" -ForegroundColor Gray
        
        $started = $process.Start()
        if ($started) {
            # Set timeout
            $completed = $process.WaitForExit($TimeoutSeconds * 1000)
            
            if ($completed) {
                $stdout = $process.StandardOutput.ReadToEnd()
                $stderr = $process.StandardError.ReadToEnd()
                
                Write-TestResult "PASS" "Script executed successfully (exit code: $($process.ExitCode))"
                $TestsPassed++
                
                if ($stdout) {
                    Write-Host ""
                    Write-Host "Standard Output:" -ForegroundColor Gray
                    Write-Host "----------------" -ForegroundColor Gray
                    Write-Host $stdout -ForegroundColor DarkGray
                }
                
                if ($stderr) {
                    Write-Host ""
                    Write-Host "Standard Error:" -ForegroundColor Gray
                    Write-Host "---------------" -ForegroundColor Gray
                    Write-Host $stderr -ForegroundColor DarkGray
                }
                
                # Analyze output
                if ($stdout -match "MediaCreationTool|MCT|Universal|Windows") {
                    Write-TestResult "PASS" "Found expected keywords in output"
                    $TestsPassed++
                } else {
                    Write-TestResult "INFO" "Expected keywords not found in output (may be normal)"
                }
                
            } else {
                $process.Kill()
                Write-TestResult "WARN" "Script execution timed out after $TimeoutSeconds seconds"
                $ErrorCount++
            }
        } else {
            Write-TestResult "FAIL" "Could not start script process"
            $ErrorCount++
        }
        
        $process.Dispose()
        
    } catch {
        Write-TestResult "FAIL" "Error executing script: $($_.Exception.Message)"
        $ErrorCount++
    }
} else {
    Write-TestResult "INFO" "Skipping script execution test (not running on Windows)"
    Write-Host "  The script is designed for Windows environments." -ForegroundColor Gray
}

# Show results
Write-Host ""
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host " TEST RESULTS SUMMARY" -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Tests passed: $TestsPassed" -ForegroundColor Green
Write-Host "Errors detected: $ErrorCount" -ForegroundColor $(if ($ErrorCount -eq 0) { "Green" } else { "Red" })
Write-Host ""

if ($TestsPassed -gt 0 -and $ErrorCount -eq 0) {
    Write-Host "[SUCCESS] MediaCreationTool.bat appears to be working correctly!" -ForegroundColor Green
    Write-Host "The script can be accessed and has expected structure." -ForegroundColor Green
} elseif ($TestsPassed -gt 0) {
    Write-Host "[PARTIAL SUCCESS] MediaCreationTool.bat can be accessed but with some issues." -ForegroundColor Yellow
    Write-Host "The script may have encountered problems during testing." -ForegroundColor Yellow
} else {
    Write-Host "[FAILURE] MediaCreationTool.bat test failed." -ForegroundColor Red
    Write-Host "The script may not be accessible or may have critical issues." -ForegroundColor Red
}

Write-Host ""
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host " ADDITIONAL INFORMATION" -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This test serves as a basic functionality check for MediaCreationTool.bat."
Write-Host "It verifies that:"
Write-Host "  1. The script file exists and is accessible"
Write-Host "  2. The script has expected content structure"
Write-Host "  3. The script can be invoked (on Windows systems)"
Write-Host "  4. Basic error detection for obvious failures"
Write-Host ""
Write-Host "For full functionality testing, run MediaCreationTool.bat manually" -ForegroundColor Gray
Write-Host "in a Windows environment with appropriate permissions." -ForegroundColor Gray
Write-Host ""
Write-Host "Test completed: $(Get-Date)" -ForegroundColor Gray
Write-Host ""

# Return appropriate exit code
if ($ErrorCount -eq 0) {
    exit 0
} else {
    exit $ErrorCount
}