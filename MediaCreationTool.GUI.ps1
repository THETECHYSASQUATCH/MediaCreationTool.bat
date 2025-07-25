#Requires -Version 3.0

<#
.SYNOPSIS
    GUI wrapper for MediaCreationTool.bat - Universal Windows Media Creation Tool
.DESCRIPTION
    Provides a user-friendly graphical interface for the MediaCreationTool.bat script
    with comprehensive error logging and real-time status updates.
.AUTHOR
    Enhanced by GitHub Copilot for improved user experience and error handling
.VERSION
    1.0.0
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Global variables
$script:LogWindow = $null
$script:MainForm = $null
$script:ProgressBar = $null
$script:StatusLabel = $null
$script:ScriptProcess = $null
$script:OutputReader = $null

# Configuration
$script:Config = @{
    FormTitle = "MediaCreationTool.bat GUI"
    FormWidth = 800
    FormHeight = 600
    LogHeight = 200
    ScriptPath = Join-Path $PSScriptRoot "MediaCreationTool.bat"
    MaxLogLines = 1000
    AutoSelectLatest = $false
    VersionDialogTimeout = 30000  # 30 seconds timeout for version dialog
}

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [System.Drawing.Color]$Color = [System.Drawing.Color]::Black
    )
    
    if ($script:LogWindow) {
        $timestamp = Get-Date -Format "HH:mm:ss"
        $logEntry = "[$timestamp] [$Level] $Message"
        
        # Add to log window
        $script:LogWindow.SelectionStart = $script:LogWindow.TextLength
        $script:LogWindow.SelectionLength = 0
        $script:LogWindow.SelectionColor = $Color
        $script:LogWindow.AppendText("$logEntry`r`n")
        
        # Limit log lines
        $lines = $script:LogWindow.Lines
        if ($lines.Count -gt $script:Config.MaxLogLines) {
            $keepLines = $lines[($lines.Count - $script:Config.MaxLogLines)..($lines.Count - 1)]
            $script:LogWindow.Text = $keepLines -join "`r`n"
        }
        
        # Auto-scroll to bottom
        $script:LogWindow.SelectionStart = $script:LogWindow.TextLength
        $script:LogWindow.ScrollToCaret()
        $script:LogWindow.Refresh()
    }
    
    # Also write to PowerShell host
    Write-Host "[$Level] $Message" -ForegroundColor $(
        switch ($Level) {
            "ERROR" { "Red" }
            "WARNING" { "Yellow" }
            "SUCCESS" { "Green" }
            default { "White" }
        }
    )
}

function Initialize-Configuration {
    param(
        [string[]]$Arguments = @()
    )
    
    # Check for auto-select command line flag
    foreach ($arg in $Arguments) {
        if ($arg -eq "-AutoSelectLatest" -or $arg -eq "/AutoSelectLatest" -or $arg -eq "--auto-latest") {
            $script:Config.AutoSelectLatest = $true
            Write-Log "Auto-select latest version enabled via command line" "INFO" ([System.Drawing.Color]::Blue)
            break
        }
    }
}

function Update-Status {
    param([string]$Status)
    
    if ($script:StatusLabel) {
        $script:StatusLabel.Text = $Status
        $script:StatusLabel.Refresh()
    }
    Write-Log $Status
}

function Start-MediaCreationTool {
    param(
        [string]$Arguments = ""
    )
    
    try {
        if (-not (Test-Path $script:Config.ScriptPath)) {
            Write-Log "ERROR: MediaCreationTool.bat not found at $($script:Config.ScriptPath)" "ERROR" ([System.Drawing.Color]::Red)
            return
        }
        
        Write-Log "Starting MediaCreationTool.bat with arguments: $Arguments" "INFO" ([System.Drawing.Color]::Blue)
        Update-Status "Initializing Media Creation Tool..."
        
        # Create process start info
        $processInfo = New-Object System.Diagnostics.ProcessStartInfo
        $processInfo.FileName = "cmd.exe"
        $processInfo.Arguments = "/c `"$($script:Config.ScriptPath)`" gui $Arguments"
        $processInfo.UseShellExecute = $false
        $processInfo.RedirectStandardOutput = $true
        $processInfo.RedirectStandardError = $true
        $processInfo.CreateNoWindow = $true
        $processInfo.WorkingDirectory = $PSScriptRoot
        
        # Start process
        $script:ScriptProcess = [System.Diagnostics.Process]::Start($processInfo)
        
        # Set up output reading
        $script:OutputReader = @{
            StandardOutput = $script:ScriptProcess.StandardOutput
            StandardError = $script:ScriptProcess.StandardError
        }
        
        # Start reading output asynchronously
        Start-OutputReading
        
        # Start progress monitoring
        Start-ProgressMonitoring
        
    } catch {
        Write-Log "Failed to start MediaCreationTool.bat: $($_.Exception.Message)" "ERROR" ([System.Drawing.Color]::Red)
        Write-Log "Please ensure:" "WARNING" ([System.Drawing.Color]::Orange)
        Write-Log "1. MediaCreationTool.bat exists in the same folder" "WARNING" ([System.Drawing.Color]::Orange)
        Write-Log "2. You have internet connection" "WARNING" ([System.Drawing.Color]::Orange)
        Write-Log "3. Antivirus is not blocking the script" "WARNING" ([System.Drawing.Color]::Orange)
        Update-Status "Error: Failed to start process"
        Enable-Controls
    }
}

function Start-OutputReading {
    # Create timer to read output periodically
    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 100
    $timer.Add_Tick({
        
        try {
            # Read standard output
            while (-not $script:ScriptProcess.StandardOutput.EndOfStream) {
                $line = $script:ScriptProcess.StandardOutput.ReadLine()
                if ($line) {
                    Invoke-ControlSafe $script:MainForm {
                        # Parse status messages
                        if ($line -match '^\[STATUS\](.*)') {
                            Update-Status $matches[1].Trim()
                        }
                        elseif ($line -match '^\[ERROR\](.*)') {
                            Write-Log $matches[1].Trim() "ERROR" ([System.Drawing.Color]::Red)
                        }
                        elseif ($line -match '^\[SUCCESS\](.*)') {
                            Write-Log $matches[1].Trim() "SUCCESS" ([System.Drawing.Color]::Green)
                        }
                        elseif ($line -match '^\[WARNING\](.*)') {
                            Write-Log $matches[1].Trim() "WARNING" ([System.Drawing.Color]::Orange)
                        }
                        else {
                            Write-Log $line "INFO"
                        }
                    }
                }
            }
            
            # Read standard error
            while (-not $script:ScriptProcess.StandardError.EndOfStream) {
                $line = $script:ScriptProcess.StandardError.ReadLine()
                if ($line) {
                    Invoke-ControlSafe $script:MainForm {
                        Write-Log $line "ERROR" ([System.Drawing.Color]::Red)
                    }
                }
            }
            
        } catch {
            # Handle errors silently as they might be expected during process termination
        }
        
        # Check if process finished
        if ($script:ScriptProcess -and $script:ScriptProcess.HasExited) {
            $this.Stop()
            Invoke-ControlSafe $script:MainForm {
                $exitCode = $script:ScriptProcess.ExitCode
                if ($exitCode -eq 0) {
                    Write-Log "Process completed successfully" "SUCCESS" ([System.Drawing.Color]::Green)
                    Update-Status "Completed successfully"
                } else {
                    Write-Log "Process completed with exit code: $exitCode" "WARNING" ([System.Drawing.Color]::Orange)
                    Update-Status "Completed with warnings/errors"
                }
                Enable-Controls
            }
        }
    })
    $timer.Start()
}

function Start-ProgressMonitoring {
    if ($script:ProgressBar) {
        $script:ProgressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Marquee
        $script:ProgressBar.MarqueeAnimationSpeed = 50
    }
    
    Disable-Controls
}

function Invoke-ControlSafe {
    param(
        [System.Windows.Forms.Control]$Control,
        [ScriptBlock]$ScriptBlock
    )
    
    if ($Control.InvokeRequired) {
        $Control.Invoke($ScriptBlock)
    } else {
        & $ScriptBlock
    }
}

function Disable-Controls {
    $script:MainForm.Controls | Where-Object { $_ -is [System.Windows.Forms.Button] } | ForEach-Object {
        $_.Enabled = $false
    }
}

function Enable-Controls {
    $script:MainForm.Controls | Where-Object { $_ -is [System.Windows.Forms.Button] } | ForEach-Object {
        $_.Enabled = $true
    }
    
    if ($script:ProgressBar) {
        $script:ProgressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Continuous
        $script:ProgressBar.Value = 0
    }
}

function Show-VersionDialog {
    param(
        [switch]$ForceShow = $false
    )
    
    $versions = @(
        "Win7 - Windows 7 Ultimate SP1",
        "Win8 - Windows 8 RTM", 
        "Win8.1 - Windows 8.1 Pro",
        "1507 - Windows 10 RTM",
        "1511 - Windows 10 November Update",
        "1607 - Windows 10 Anniversary Update",
        "1703 - Windows 10 Creators Update",
        "1709 - Windows 10 Fall Creators Update",
        "1803 - Windows 10 April 2018 Update",
        "1809 - Windows 10 October 2018 Update",
        "1903 - Windows 10 May 2019 Update",
        "1909 - Windows 10 November 2019 Update",
        "20H1 - Windows 10 May 2020 Update",
        "20H2 - Windows 10 October 2020 Update",
        "21H1 - Windows 10 May 2021 Update",
        "21H2 - Windows 10 November 2021 Update",
        "22H2 - Windows 10 2022 Update",
        "11_21H2 - Windows 11 (Original)",
        "11_22H2 - Windows 11 2022 Update",
        "11_23H2 - Windows 11 2023 Update",
        "11_24H2 - Windows 11 2024 Update (Latest)",
        "Insider_Dev - Windows Insider Dev Channel",
        "Insider_Beta - Windows Insider Beta Channel", 
        "Insider_RP - Windows Insider Release Preview"
    )
    
    $latestVersion = ($versions[-1] -split " - ")[0]
    
    # Check if auto-select mode is enabled and not forcing manual selection
    if ($script:Config.AutoSelectLatest -and -not $ForceShow) {
        Write-Log "Auto-select mode enabled: Using latest version ($latestVersion)" "INFO" ([System.Drawing.Color]::Blue)
        return $latestVersion
    }
    
    Write-Log "Showing Windows version selection dialog" "INFO"
    
    try {
        $form = New-Object System.Windows.Forms.Form
        $form.Text = "Select Windows Version"
        $form.Size = New-Object System.Drawing.Size(500, 480)
        $form.StartPosition = "CenterParent"
        $form.FormBorderStyle = "FixedDialog"
        $form.MaximizeBox = $false
        $form.TopMost = $true
        
        # Add auto-select checkbox
        $autoCheckBox = New-Object System.Windows.Forms.CheckBox
        $autoCheckBox.Text = "Always use latest version automatically (skips this dialog)"
        $autoCheckBox.Location = New-Object System.Drawing.Point(10, 10)
        $autoCheckBox.Size = New-Object System.Drawing.Size(460, 20)
        $autoCheckBox.Checked = $script:Config.AutoSelectLatest
        $form.Controls.Add($autoCheckBox)
        
        # Add instruction label
        $instructionLabel = New-Object System.Windows.Forms.Label
        $instructionLabel.Text = "Select a Windows version to download:"
        $instructionLabel.Location = New-Object System.Drawing.Point(10, 35)
        $instructionLabel.Size = New-Object System.Drawing.Size(460, 20)
        $form.Controls.Add($instructionLabel)
        
        $listBox = New-Object System.Windows.Forms.ListBox
        $listBox.Location = New-Object System.Drawing.Point(10, 60)
        $listBox.Size = New-Object System.Drawing.Size(460, 320)
        
        foreach ($version in $versions) {
            $listBox.Items.Add($version) | Out-Null
        }
        
        $listBox.SelectedIndex = $versions.Count - 1  # Default to latest
        $form.Controls.Add($listBox)
        
        $okButton = New-Object System.Windows.Forms.Button
        $okButton.Location = New-Object System.Drawing.Point(300, 390)
        $okButton.Size = New-Object System.Drawing.Size(75, 23)
        $okButton.Text = "OK"
        $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form.Controls.Add($okButton)
        
        $cancelButton = New-Object System.Windows.Forms.Button
        $cancelButton.Location = New-Object System.Drawing.Point(395, 390)
        $cancelButton.Size = New-Object System.Drawing.Size(75, 23)
        $cancelButton.Text = "Cancel"
        $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
        $form.Controls.Add($cancelButton)
        
        # Add timeout handling
        $timer = New-Object System.Windows.Forms.Timer
        $timer.Interval = $script:Config.VersionDialogTimeout
        $timer.Add_Tick({
            Write-Log "Version selection dialog timed out after $($script:Config.VersionDialogTimeout/1000) seconds" "WARNING" ([System.Drawing.Color]::Orange)
            Write-Log "Defaulting to latest version: $latestVersion" "WARNING" ([System.Drawing.Color]::Orange)
            $form.DialogResult = [System.Windows.Forms.DialogResult]::OK
            $listBox.SelectedIndex = $versions.Count - 1
            $timer.Stop()
            $form.Close()
        })
        $timer.Start()
        
        $form.AcceptButton = $okButton
        $form.CancelButton = $cancelButton
        
        $result = $form.ShowDialog()
        $timer.Stop()
        
        if ($result -eq [System.Windows.Forms.DialogResult]::OK -and $listBox.SelectedItem) {
            $selectedVersion = ($listBox.SelectedItem -split " - ")[0]
            
            # Update auto-select setting if changed
            if ($autoCheckBox.Checked -ne $script:Config.AutoSelectLatest) {
                $script:Config.AutoSelectLatest = $autoCheckBox.Checked
                if ($autoCheckBox.Checked) {
                    Write-Log "Auto-select mode enabled: Future operations will use latest version automatically" "SUCCESS" ([System.Drawing.Color]::Green)
                } else {
                    Write-Log "Auto-select mode disabled: Future operations will show version selection dialog" "INFO" ([System.Drawing.Color]::Blue)
                }
            }
            
            Write-Log "User selected Windows version: $selectedVersion" "SUCCESS" ([System.Drawing.Color]::Green)
            return $selectedVersion
        } else {
            Write-Log "Version selection cancelled by user" "WARNING" ([System.Drawing.Color]::Orange)
            return $null
        }
        
    } catch {
        Write-Log "Error displaying version selection dialog: $($_.Exception.Message)" "ERROR" ([System.Drawing.Color]::Red)
        Write-Log "Falling back to latest version: $latestVersion" "WARNING" ([System.Drawing.Color]::Orange)
        return $latestVersion
    }
}

function Create-MainForm {
    # Create main form
    $script:MainForm = New-Object System.Windows.Forms.Form
    $script:MainForm.Text = $script:Config.FormTitle
    $script:MainForm.Size = New-Object System.Drawing.Size($script:Config.FormWidth, $script:Config.FormHeight)
    $script:MainForm.StartPosition = "CenterScreen"
    $script:MainForm.FormBorderStyle = "FixedSingle"
    $script:MainForm.MaximizeBox = $false
    
    # Create title label
    $titleLabel = New-Object System.Windows.Forms.Label
    $titleLabel.Text = "Universal Windows Media Creation Tool"
    $titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $titleLabel.Location = New-Object System.Drawing.Point(10, 10)
    $titleLabel.Size = New-Object System.Drawing.Size(760, 30)
    $titleLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $script:MainForm.Controls.Add($titleLabel)
    
    # Create description label
    $descLabel = New-Object System.Windows.Forms.Label
    $descLabel.Text = "Select an option below to create Windows installation media or upgrade your system."
    $descLabel.Location = New-Object System.Drawing.Point(10, 45)
    $descLabel.Size = New-Object System.Drawing.Size(760, 20)
    $descLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $script:MainForm.Controls.Add($descLabel)
    
    # Create hint label for auto-select mode
    $hintLabel = New-Object System.Windows.Forms.Label
    $hintLabel.Text = "Tip: Hold Shift while clicking to force version selection dialog (when auto-select is enabled)"
    $hintLabel.Location = New-Object System.Drawing.Point(10, 65)
    $hintLabel.Size = New-Object System.Drawing.Size(760, 15)
    $hintLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $hintLabel.ForeColor = [System.Drawing.Color]::DarkBlue
    $hintLabel.Font = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Italic)
    $script:MainForm.Controls.Add($hintLabel)
    
    # Create preset buttons
    $buttonY = 90
    $buttonHeight = 60
    $buttonSpacing = 70
    
    # Auto Upgrade button
    $autoUpgradeBtn = New-Object System.Windows.Forms.Button
    $autoUpgradeBtn.Text = "Auto Upgrade`r`nUpgrade current system with detected media"
    $autoUpgradeBtn.Location = New-Object System.Drawing.Point(10, $buttonY)
    $autoUpgradeBtn.Size = New-Object System.Drawing.Size(180, $buttonHeight)
    $autoUpgradeBtn.BackColor = [System.Drawing.Color]::LightBlue
    $autoUpgradeBtn.Add_Click({
        $forceShow = [System.Windows.Forms.Control]::ModifierKeys -eq [System.Windows.Forms.Keys]::Shift
        $version = Show-VersionDialog -ForceShow:$forceShow
        if ($version) {
            Start-MediaCreationTool "auto $version"
        }
    })
    $script:MainForm.Controls.Add($autoUpgradeBtn)
    
    # Auto ISO button
    $autoISOBtn = New-Object System.Windows.Forms.Button
    $autoISOBtn.Text = "Auto ISO`r`nCreate ISO with detected media in current folder"
    $autoISOBtn.Location = New-Object System.Drawing.Point(200, $buttonY)
    $autoISOBtn.Size = New-Object System.Drawing.Size(180, $buttonHeight)
    $autoISOBtn.BackColor = [System.Drawing.Color]::LightGreen
    $autoISOBtn.Add_Click({
        $forceShow = [System.Windows.Forms.Control]::ModifierKeys -eq [System.Windows.Forms.Keys]::Shift
        $version = Show-VersionDialog -ForceShow:$forceShow
        if ($version) {
            Start-MediaCreationTool "iso $version"
        }
    })
    $script:MainForm.Controls.Add($autoISOBtn)
    
    # Auto USB button
    $autoUSBBtn = New-Object System.Windows.Forms.Button
    $autoUSBBtn.Text = "Auto USB`r`nCreate bootable USB with detected media"
    $autoUSBBtn.Location = New-Object System.Drawing.Point(390, $buttonY)
    $autoUSBBtn.Size = New-Object System.Drawing.Size(180, $buttonHeight)
    $autoUSBBtn.BackColor = [System.Drawing.Color]::LightYellow
    $autoUSBBtn.Add_Click({
        $forceShow = [System.Windows.Forms.Control]::ModifierKeys -eq [System.Windows.Forms.Keys]::Shift
        $version = Show-VersionDialog -ForceShow:$forceShow
        if ($version) {
            Start-MediaCreationTool "$version"
        }
    })
    $script:MainForm.Controls.Add($autoUSBBtn)
    
    # Select button
    $selectBtn = New-Object System.Windows.Forms.Button
    $selectBtn.Text = "Select Options`r`nChoose Edition, Language, Architecture manually"
    $selectBtn.Location = New-Object System.Drawing.Point(580, $buttonY)
    $selectBtn.Size = New-Object System.Drawing.Size(180, $buttonHeight)
    $selectBtn.BackColor = [System.Drawing.Color]::LightCoral
    $selectBtn.Add_Click({
        Start-MediaCreationTool ""
    })
    $script:MainForm.Controls.Add($selectBtn)
    
    # MCT Defaults button
    $defaultBtn = New-Object System.Windows.Forms.Button
    $defaultBtn.Text = "MCT Defaults`r`nRun unmodified Microsoft Media Creation Tool"
    $defaultBtnY = $buttonY + $buttonSpacing
    $defaultBtn.Location = New-Object System.Drawing.Point(295, $defaultBtnY)
    $defaultBtn.Size = New-Object System.Drawing.Size(180, $buttonHeight)
    $defaultBtn.BackColor = [System.Drawing.Color]::LightGray
    $defaultBtn.Add_Click({
        Start-MediaCreationTool "def"
    })
    $script:MainForm.Controls.Add($defaultBtn)
    
    # Progress bar
    $script:ProgressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBarY = $buttonY + $buttonSpacing + 80
    $script:ProgressBar.Location = New-Object System.Drawing.Point(10, $progressBarY)
    $script:ProgressBar.Size = New-Object System.Drawing.Size(760, 20)
    $script:MainForm.Controls.Add($script:ProgressBar)
    
    # Status label
    $script:StatusLabel = New-Object System.Windows.Forms.Label
    $script:StatusLabel.Text = "Ready"
    $statusLabelY = $buttonY + $buttonSpacing + 105
    $script:StatusLabel.Location = New-Object System.Drawing.Point(10, $statusLabelY)
    $script:StatusLabel.Size = New-Object System.Drawing.Size(760, 20)
    $script:MainForm.Controls.Add($script:StatusLabel)
    
    # Log window
    $script:LogWindow = New-Object System.Windows.Forms.RichTextBox
    $logWindowY = $buttonY + $buttonSpacing + 130
    $script:LogWindow.Location = New-Object System.Drawing.Point(10, $logWindowY)
    $script:LogWindow.Size = New-Object System.Drawing.Size(760, $script:Config.LogHeight)
    $script:LogWindow.ReadOnly = $true
    $script:LogWindow.BackColor = [System.Drawing.Color]::Black
    $script:LogWindow.ForeColor = [System.Drawing.Color]::White
    $script:LogWindow.Font = New-Object System.Drawing.Font("Consolas", 9)
    $script:LogWindow.ScrollBars = "Vertical"
    $script:MainForm.Controls.Add($script:LogWindow)
    
    # Clear log button
    $clearLogBtn = New-Object System.Windows.Forms.Button
    $clearLogBtn.Text = "Clear Log"
    $clearLogBtnY = $script:Config.FormHeight - 70
    $clearLogBtn.Location = New-Object System.Drawing.Point(10, $clearLogBtnY)
    $clearLogBtn.Size = New-Object System.Drawing.Size(80, 25)
    $clearLogBtn.Add_Click({
        $script:LogWindow.Clear()
        Write-Log "Log cleared" "INFO"
    })
    $script:MainForm.Controls.Add($clearLogBtn)
    
    # Help button
    $helpBtn = New-Object System.Windows.Forms.Button
    $helpBtn.Text = "Help"
    $helpBtnY = $script:Config.FormHeight - 70
    $helpBtn.Location = New-Object System.Drawing.Point(100, $helpBtnY)
    $helpBtn.Size = New-Object System.Drawing.Size(80, 25)
    $helpBtn.Add_Click({
        Show-HelpDialog
    })
    $script:MainForm.Controls.Add($helpBtn)
    
    # Settings button
    $settingsBtn = New-Object System.Windows.Forms.Button
    $settingsBtn.Text = "Settings"
    $settingsBtnY = $script:Config.FormHeight - 70
    $settingsBtn.Location = New-Object System.Drawing.Point(190, $settingsBtnY)
    $settingsBtn.Size = New-Object System.Drawing.Size(80, 25)
    $settingsBtn.Add_Click({
        Show-SettingsDialog
    })
    $script:MainForm.Controls.Add($settingsBtn)
    
    # Close button
    $closeBtn = New-Object System.Windows.Forms.Button
    $closeBtn.Text = "Close"
    $closeBtnY = $script:Config.FormHeight - 70
    $closeBtn.Location = New-Object System.Drawing.Point(690, $closeBtnY)
    $closeBtn.Size = New-Object System.Drawing.Size(80, 25)
    $closeBtn.Add_Click({
        $script:MainForm.Close()
    })
    $script:MainForm.Controls.Add($closeBtn)
    
    # Handle form closing
    $script:MainForm.Add_FormClosing({
        if ($script:ScriptProcess -and -not $script:ScriptProcess.HasExited) {
            $result = [System.Windows.Forms.MessageBox]::Show(
                "Media Creation Tool is still running. Do you want to terminate it?",
                "Confirm Close",
                [System.Windows.Forms.MessageBoxButtons]::YesNo,
                [System.Windows.Forms.MessageBoxIcon]::Question
            )
            
            if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
                try {
                    $script:ScriptProcess.Kill()
                    Write-Log "Process terminated by user" "WARNING" ([System.Drawing.Color]::Orange)
                } catch {
                    Write-Log "Failed to terminate process: $($_.Exception.Message)" "ERROR" ([System.Drawing.Color]::Red)
                }
            } else {
                $_.Cancel = $true
            }
        }
    })
    
    Write-Log "GUI initialized successfully" "SUCCESS" ([System.Drawing.Color]::Green)
    Write-Log "MediaCreationTool.bat path: $($script:Config.ScriptPath)" "INFO"
    
    if (-not (Test-Path $script:Config.ScriptPath)) {
        Write-Log "WARNING: MediaCreationTool.bat not found!" "WARNING" ([System.Drawing.Color]::Orange)
        Write-Log "Please ensure MediaCreationTool.bat is in the same folder as this script." "WARNING" ([System.Drawing.Color]::Orange)
    }
}

function Show-SettingsDialog {
    $settingsForm = New-Object System.Windows.Forms.Form
    $settingsForm.Text = "Settings - MediaCreationTool.bat GUI"
    $settingsForm.Size = New-Object System.Drawing.Size(450, 200)
    $settingsForm.StartPosition = "CenterParent"
    $settingsForm.FormBorderStyle = "FixedDialog"
    $settingsForm.MaximizeBox = $false
    
    # Auto-select checkbox
    $autoCheckBox = New-Object System.Windows.Forms.CheckBox
    $autoCheckBox.Text = "Always use latest Windows version automatically"
    $autoCheckBox.Location = New-Object System.Drawing.Point(20, 20)
    $autoCheckBox.Size = New-Object System.Drawing.Size(400, 20)
    $autoCheckBox.Checked = $script:Config.AutoSelectLatest
    $settingsForm.Controls.Add($autoCheckBox)
    
    # Description label
    $descLabel = New-Object System.Windows.Forms.Label
    $descLabel.Text = "When enabled, version selection dialogs will be skipped and the latest Windows version will be used automatically."
    $descLabel.Location = New-Object System.Drawing.Point(40, 45)
    $descLabel.Size = New-Object System.Drawing.Size(360, 40)
    $descLabel.ForeColor = [System.Drawing.Color]::DarkBlue
    $settingsForm.Controls.Add($descLabel)
    
    # Timeout setting
    $timeoutLabel = New-Object System.Windows.Forms.Label
    $timeoutLabel.Text = "Version dialog timeout (seconds):"
    $timeoutLabel.Location = New-Object System.Drawing.Point(20, 95)
    $timeoutLabel.Size = New-Object System.Drawing.Size(180, 20)
    $settingsForm.Controls.Add($timeoutLabel)
    
    $timeoutNumeric = New-Object System.Windows.Forms.NumericUpDown
    $timeoutNumeric.Location = New-Object System.Drawing.Point(200, 93)
    $timeoutNumeric.Size = New-Object System.Drawing.Size(60, 20)
    $timeoutNumeric.Minimum = 10
    $timeoutNumeric.Maximum = 300
    $timeoutNumeric.Value = $script:Config.VersionDialogTimeout / 1000
    $settingsForm.Controls.Add($timeoutNumeric)
    
    # OK button
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Text = "OK"
    $okButton.Location = New-Object System.Drawing.Point(280, 130)
    $okButton.Size = New-Object System.Drawing.Size(75, 25)
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $settingsForm.Controls.Add($okButton)
    
    # Cancel button
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Text = "Cancel"
    $cancelButton.Location = New-Object System.Drawing.Point(365, 130)
    $cancelButton.Size = New-Object System.Drawing.Size(75, 25)
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $settingsForm.Controls.Add($cancelButton)
    
    $settingsForm.AcceptButton = $okButton
    $settingsForm.CancelButton = $cancelButton
    
    $result = $settingsForm.ShowDialog()
    
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $oldAutoSelect = $script:Config.AutoSelectLatest
        $oldTimeout = $script:Config.VersionDialogTimeout
        
        $script:Config.AutoSelectLatest = $autoCheckBox.Checked
        $script:Config.VersionDialogTimeout = $timeoutNumeric.Value * 1000
        
        if ($oldAutoSelect -ne $script:Config.AutoSelectLatest) {
            if ($script:Config.AutoSelectLatest) {
                Write-Log "Auto-select mode enabled: Future operations will use latest version automatically" "SUCCESS" ([System.Drawing.Color]::Green)
            } else {
                Write-Log "Auto-select mode disabled: Future operations will show version selection dialog" "INFO" ([System.Drawing.Color]::Blue)
            }
        }
        
        if ($oldTimeout -ne $script:Config.VersionDialogTimeout) {
            Write-Log "Version dialog timeout changed to $($script:Config.VersionDialogTimeout/1000) seconds" "INFO"
        }
    }
}

function Show-HelpDialog {
    $helpText = @"
MediaCreationTool.bat GUI Help

OVERVIEW:
This GUI provides an easy-to-use interface for the MediaCreationTool.bat script, which creates Windows installation media for versions 7, 8, 8.1, 10, and 11.

NEW FEATURES:
- Auto-Select Latest Version: Enable automatic selection of the latest Windows version
- Version Dialog Timeout: Automatic fallback to latest version if dialog times out
- Enhanced Error Handling: Robust fallback mechanisms for failed dialogs
- Comprehensive Logging: Detailed logs for all version selection activities

PRESETS:

1. Auto Upgrade
   - Upgrades your current system using detected media
   - Script assists with setup preparation
   - Keeps files and apps when possible

2. Auto ISO
   - Creates an ISO file with detected media
   - Saves to current folder or C:\ESD
   - Includes script modifications for better compatibility

3. Auto USB
   - Creates bootable USB media
   - Must manually select USB drive in MCT interface
   - Includes TPM bypass for Windows 11

4. Select Options
   - Manually choose Edition, Language, Architecture
   - Full control over media creation options
   - Uses MCT interface for selection

5. MCT Defaults
   - Runs unmodified Microsoft Media Creation Tool
   - No script enhancements or modifications
   - Original Microsoft experience

AUTO-SELECT MODE:
When enabled via Settings or command line (-AutoSelectLatest), the version selection dialog will be skipped and the latest Windows version will be used automatically. This is useful for automated scenarios or users who always want the latest version.

SUPPORTED VERSIONS:
- Windows 7 Ultimate SP1
- Windows 8/8.1
- Windows 10 (all versions from 1507 to 22H2)
- Windows 11 (21H2, 22H2, 23H2, 24H2)
- Windows Insider Builds (Dev, Beta, Release Preview)

COMMAND LINE OPTIONS:
- -AutoSelectLatest: Enable auto-select mode for this session
- /AutoSelectLatest: Alternative syntax for auto-select mode
- --auto-latest: Alternative syntax for auto-select mode

WINDOWS INSIDER BUILDS:
- Dev Channel: Latest cutting-edge builds (may be unstable)
- Beta Channel: More stable builds than Dev channel
- Release Preview: Near-final builds before public release
- Requires Windows Insider Program enrollment
- Falls back to Windows 11 24H2 if Insider access unavailable

TROUBLESHOOTING:
- Check the log window for detailed error messages
- Ensure you have internet connection
- Run as Administrator if needed
- Temporarily disable antivirus if downloads fail
- Check firewall settings
- If version dialog fails, it will automatically default to latest version

For more information, visit the GitHub repository.
"@

    $helpForm = New-Object System.Windows.Forms.Form
    $helpForm.Text = "Help - MediaCreationTool.bat GUI"
    $helpForm.Size = New-Object System.Drawing.Size(600, 500)
    $helpForm.StartPosition = "CenterParent"
    $helpForm.FormBorderStyle = "FixedDialog"
    $helpForm.MaximizeBox = $false
    
    $helpTextBox = New-Object System.Windows.Forms.TextBox
    $helpTextBox.Multiline = $true
    $helpTextBox.ReadOnly = $true
    $helpTextBox.ScrollBars = "Vertical"
    $helpTextBox.Text = $helpText
    $helpTextBox.Location = New-Object System.Drawing.Point(10, 10)
    $helpTextBox.Size = New-Object System.Drawing.Size(565, 420)
    $helpTextBox.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $helpForm.Controls.Add($helpTextBox)
    
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Text = "OK"
    $okButton.Location = New-Object System.Drawing.Point(500, 440)
    $okButton.Size = New-Object System.Drawing.Size(75, 25)
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $helpForm.Controls.Add($okButton)
    
    $helpForm.AcceptButton = $okButton
    $helpForm.ShowDialog() | Out-Null
}

# Main entry point
function Start-GUI {
    param(
        [string[]]$Arguments = $args
    )
    
    try {
        # Check if we can run the GUI
        if (-not ([System.Environment]::UserInteractive)) {
            Write-Error "This script requires an interactive session to display the GUI."
            return
        }
        
        # Initialize configuration with command line arguments
        Initialize-Configuration -Arguments $Arguments
        
        # Enable visual styles
        [System.Windows.Forms.Application]::EnableVisualStyles()
        [System.Windows.Forms.Application]::SetCompatibleTextRenderingDefault($false)
        
        Create-MainForm
        
        Write-Log "Starting MediaCreationTool.bat GUI..." "INFO" ([System.Drawing.Color]::Blue)
        Write-Log "Ready to create Windows installation media" "INFO"
        
        if ($script:Config.AutoSelectLatest) {
            Write-Log "Auto-select mode is enabled - latest version will be used automatically" "INFO" ([System.Drawing.Color]::Green)
        }
        
        # Show the form
        [System.Windows.Forms.Application]::Run($script:MainForm)
        
    } catch {
        Write-Error "Failed to start GUI: $($_.Exception.Message)"
        Write-Error $_.Exception.StackTrace
    } finally {
        # Cleanup
        if ($script:ScriptProcess -and -not $script:ScriptProcess.HasExited) {
            try {
                $script:ScriptProcess.Kill()
            } catch {}
        }
    }
}

# Start the GUI if script is run directly
if ($MyInvocation.InvocationName -ne ".") {
    Start-GUI -Arguments $args
}