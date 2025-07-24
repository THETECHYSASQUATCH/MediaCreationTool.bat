# MediaCreationTool.bat GUI

A user-friendly graphical interface for the MediaCreationTool.bat script that provides enhanced error reporting and real-time status updates.

## What's New

The original MediaCreationTool.bat script now includes a modern GUI wrapper that:

- ✅ **Visual Interface**: Easy-to-use buttons for each media creation option
- ✅ **Real-time Logging**: Live output capture with color-coded messages
- ✅ **Better Error Handling**: Detailed error messages with troubleshooting suggestions
- ✅ **Status Updates**: Progress tracking and current operation display
- ✅ **Version Selection**: Interactive dialog to choose Windows version
- ✅ **Help System**: Built-in help with usage instructions

## Files Included

- `MediaCreationTool.bat` - Enhanced original script with GUI support
- `MediaCreationTool.GUI.ps1` - PowerShell GUI wrapper
- `Start-GUI.bat` - Simple launcher to start the GUI
- `GUI-README.md` - This documentation file

## Quick Start

### Option 1: Double-click Launcher
1. Double-click `Start-GUI.bat` to launch the GUI interface
2. Select your desired preset option
3. Choose Windows version when prompted
4. Monitor progress in the log window

### Option 2: PowerShell Direct
1. Right-click `MediaCreationTool.GUI.ps1` → "Run with PowerShell"
2. Or from PowerShell: `.\MediaCreationTool.GUI.ps1`

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

### Log Window
- Real-time output from the script
- Color-coded messages (Info/Warning/Error/Success)
- Auto-scrolling with line limit management
- Clear log button for fresh start

### Status Bar
- Current operation status
- Progress indication during operations
- Visual feedback for user actions

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

## Troubleshooting

### GUI Won't Start
- Ensure PowerShell is installed and enabled
- Check execution policy: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
- Verify all files are in the same directory
- Run as Administrator if needed

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
- **Frontend**: PowerShell Windows Forms GUI
- **Backend**: Enhanced batch script with status reporting
- **Communication**: Standard output parsing with message tags
- **Error Handling**: Multi-level error capture and reporting

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

## Backward Compatibility

- Original command-line functionality preserved
- All existing command-line arguments supported
- Script behavior unchanged when GUI mode not active
- Can be used in automation scripts without modification

## Contributing

This GUI enhancement maintains the original script's functionality while adding user-friendly features. All core MediaCreationTool.bat features remain available and unchanged.

For issues or improvements, please refer to the main repository.