# MediaCreationTool.bat GUI

A user-friendly graphical interface for the MediaCreationTool.bat script that provides enhanced error reporting, real-time status updates, and automated version selection capabilities.

## What's New

The original MediaCreationTool.bat script now includes a modern GUI wrapper that:

- ✅ **Visual Interface**: Easy-to-use buttons for each media creation option
- ✅ **Real-time Logging**: Live output capture with color-coded messages
- ✅ **Better Error Handling**: Detailed error messages with troubleshooting suggestions
- ✅ **Status Updates**: Progress tracking and current operation display
- ✅ **Version Selection**: Interactive dialog to choose Windows version
- ✅ **Help System**: Built-in help with usage instructions
- ✅ **Auto-Select Mode**: Automatically use latest Windows version (NEW)
- ✅ **Timeout Handling**: Automatic fallback if version dialog times out (NEW)
- ✅ **Settings Dialog**: Configure auto-select and timeout preferences (NEW)
- ✅ **Command-Line Support**: Enable auto-select mode via command line flags (NEW)

## Enhanced Features

### Automated Version Selection
- **Auto-Select Latest**: Enable automatic selection of the latest Windows version
- **Skip Dialog**: When auto-select is enabled, version selection dialogs are bypassed
- **Manual Override**: Hold Shift while clicking any button to force version selection dialog
- **Timeout Protection**: If version dialog doesn't respond within 30 seconds, defaults to latest version
- **Comprehensive Logging**: All version selection activities are logged with timestamps

### Configuration Options
- **Settings Dialog**: Access via the Settings button to configure preferences
- **Persistent Settings**: Auto-select preference is remembered within the session
- **Configurable Timeout**: Adjust the version dialog timeout (10-300 seconds)
- **Command-Line Flags**: Use `-AutoSelectLatest`, `/AutoSelectLatest`, or `--auto-latest` to enable auto-select mode

## Files Included

- `MediaCreationTool.bat` - Enhanced original script with GUI support
- `MediaCreationTool.GUI.ps1` - PowerShell GUI wrapper with automation features
- `Start-GUI.bat` - Simple launcher to start the GUI
- `GUI-README.md` - This documentation file

## Quick Start

### Option 1: Double-click Launcher
1. Double-click `Start-GUI.bat` to launch the GUI interface
2. Configure auto-select mode via Settings if desired
3. Select your desired preset option
4. Choose Windows version when prompted (unless auto-select is enabled)
5. Monitor progress in the log window

### Option 2: PowerShell Direct
1. Right-click `MediaCreationTool.GUI.ps1` → "Run with PowerShell"
2. Or from PowerShell: `.\MediaCreationTool.GUI.ps1`
3. For auto-select mode: `.\MediaCreationTool.GUI.ps1 -AutoSelectLatest`

### Option 3: Original Command Line
The original command-line interface remains fully functional:
```cmd
MediaCreationTool.bat
MediaCreationTool.bat auto 11_23H2
MediaCreationTool.bat iso 22H2
```

## GUI Features

### Main Interface
- **Auto Upgrade**: Upgrade current system with detected media
- **Auto ISO**: Create ISO file in current folder
- **Auto USB**: Create bootable USB media (manual drive selection)
- **Select Options**: Full manual control over edition/language/architecture
- **MCT Defaults**: Run unmodified Microsoft Media Creation Tool

### Auto-Select Mode
When enabled (via Settings or command line):
- Version selection dialogs are automatically skipped
- Latest Windows version (11_23H2) is used automatically
- Logged events provide transparency into automatic selections
- Manual override available with Shift+Click on any preset button

### Enhanced Version Dialog
When auto-select is disabled or manually overridden:
- List of all available Windows versions
- Auto-select checkbox for enabling automatic mode
- Timeout protection (defaults to latest version after 30 seconds)
- Clear logging of user selections

### Settings Dialog
- **Auto-Select Toggle**: Enable/disable automatic latest version selection
- **Timeout Configuration**: Set version dialog timeout (10-300 seconds)
- **Persistent Preferences**: Settings remembered within the current session

### Log Window
- Real-time output from the script
- Color-coded messages (Info/Warning/Error/Success)
- Auto-scrolling with line limit management
- Clear log button for fresh start
- Enhanced logging for version selection activities

### Status Bar
- Current operation status
- Progress indication during operations
- Visual feedback for user actions

## Command Line Options

### Auto-Select Flags
- `-AutoSelectLatest`: Enable auto-select mode for this session
- `/AutoSelectLatest`: Alternative syntax for auto-select mode
- `--auto-latest`: Alternative syntax for auto-select mode

### Usage Examples
```powershell
# Enable auto-select mode
.\MediaCreationTool.GUI.ps1 -AutoSelectLatest

# Alternative syntax
.\MediaCreationTool.GUI.ps1 /AutoSelectLatest
.\MediaCreationTool.GUI.ps1 --auto-latest
```

## Supported Windows Versions

- **Windows 7**: Ultimate SP1 (archived sources)
- **Windows 8/8.1**: RTM/Pro versions (archived sources)
- **Windows 10**: All versions from 1507 to 22H2
- **Windows 11**: 21H2, 22H2, 23H2 (latest)

## Error Handling Improvements

The enhanced script now provides:

- **Detailed Error Messages**: Specific causes and solutions
- **Network Troubleshooting**: Connection and firewall guidance
- **Version Validation**: Availability checking for selected versions
- **Fallback Sources**: Multiple download sources for reliability
- **GUI Integration**: Error messages displayed in log window with color coding
- **Timeout Protection**: Automatic fallback to latest version if dialog fails
- **Robust Recovery**: Graceful handling of dialog failures and timeouts

## Troubleshooting

### GUI Won't Start
- Ensure PowerShell is installed and enabled
- Check execution policy: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
- Verify all files are in the same directory
- Run as Administrator if needed

### Version Dialog Issues
- If dialog times out, latest version is automatically selected
- Check the log window for timeout notifications
- Adjust timeout in Settings if needed
- Use auto-select mode to bypass dialog entirely

### Download Failures
- Check internet connection
- Temporarily disable antivirus/firewall
- Try a different Windows version
- Check the log window for specific error details

### Process Hangs
- Use the Close button to terminate safely
- Check Windows Task Manager for hanging processes
- Restart and try with different settings

## Requirements

- Windows 7 or later
- PowerShell 3.0 or later (included in Windows 8+)
- .NET Framework 3.5 or later
- Internet connection for downloading
- Administrative privileges (for some operations)

## Technical Details

### Architecture
- **Frontend**: PowerShell Windows Forms GUI with automation features
- **Backend**: Enhanced batch script with status reporting
- **Communication**: Standard output parsing with message tags
- **Error Handling**: Multi-level error capture and reporting
- **Configuration**: Session-persistent settings with command-line overrides

### Status Messages
The enhanced script now outputs structured messages:
- `[STATUS] Operation description` - Current operation
- `[ERROR] Error description` - Error messages
- `[SUCCESS] Success message` - Successful operations
- `[WARNING] Warning message` - Non-critical issues

### Log Format
```
[HH:mm:ss] [LEVEL] Message content
```

### Auto-Select Logic
1. Check command-line flags for auto-select mode
2. Check Settings dialog configuration
3. If auto-select enabled and not overridden: return latest version
4. If auto-select disabled or Shift+Click: show version dialog
5. If dialog times out or fails: fallback to latest version
6. Log all selection events with context

## Backward Compatibility

- Original command-line functionality preserved
- All existing command-line arguments supported
- Script behavior unchanged when GUI mode not active
- Can be used in automation scripts without modification
- New features are opt-in and don't affect existing workflows

## Contributing

This GUI enhancement maintains the original script's functionality while adding user-friendly automation features. All core MediaCreationTool.bat features remain available and unchanged.

For issues or improvements, please refer to the main repository.