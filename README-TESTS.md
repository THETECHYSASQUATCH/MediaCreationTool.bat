# MediaCreationTool.bat - Basic Functionality Tests

This directory contains minimal test scripts to verify that MediaCreationTool.bat can be invoked and produces expected output. These tests serve as basic functionality checks for CI/CD pipelines or manual verification.

## Test Files

### 1. test-basic-functionality.bat
A Windows batch file that performs basic functionality testing of MediaCreationTool.bat.

**Features:**
- Checks if MediaCreationTool.bat exists
- Attempts to invoke the script with help parameter
- Captures and analyzes output
- Provides clear pass/fail results
- Includes timeout protection to prevent hanging

**Usage:**
```cmd
# Run from the same directory as MediaCreationTool.bat
test-basic-functionality.bat
```

### 2. test-basic-functionality.ps1
A PowerShell script that provides more robust testing capabilities.

**Features:**
- Cross-platform compatibility (Windows/Linux/macOS)
- Content structure verification
- Better error handling and output formatting
- Colored output for better readability
- Configurable timeout settings

**Usage:**
```powershell
# Basic usage
.\test-basic-functionality.ps1

# With custom timeout (default is 10 seconds)
.\test-basic-functionality.ps1 -TimeoutSeconds 15

# With verbose output
.\test-basic-functionality.ps1 -Verbose
```

## What These Tests Verify

1. **File Accessibility**: Confirms MediaCreationTool.bat exists and can be read
2. **Script Structure**: Verifies the script contains expected content patterns
3. **Basic Invocation**: Tests that the script can be started (Windows only)
4. **Output Analysis**: Checks for expected keywords and error detection
5. **Error Handling**: Provides clear feedback on any issues encountered

## Expected Output

### Successful Test Run
```
===================================================================
 MediaCreationTool.bat - Basic Functionality Test
===================================================================

[TEST 1] Checking if MediaCreationTool.bat exists...
[PASS] MediaCreationTool.bat found

[TEST 2] Attempting to read script content and verify structure...
[PASS] Found 'Universal MCT wrapper' in script content
[PASS] Found MediaCreationTool or repository reference
[PASS] Valid batch script structure detected

[SUCCESS] MediaCreationTool.bat appears to be working correctly!
```

### Test Failure Example
```
[TEST 1] Checking if MediaCreationTool.bat exists...
[FAIL] MediaCreationTool.bat not found in current directory

[FAILURE] MediaCreationTool.bat test failed.
The script may not be accessible or may have critical issues.
```

## Return Codes

Both test scripts return appropriate exit codes:
- **0**: All tests passed successfully
- **1+**: Number of errors encountered

This makes them suitable for use in automated testing environments.

## Limitations

1. **Windows Environment**: Full testing requires a Windows environment
2. **Permissions**: Some tests may require administrator privileges
3. **Network Access**: The main script may require internet connectivity
4. **Basic Testing**: These are minimal tests and don't verify full functionality

## Use Cases

### Manual Testing
Run these tests after making changes to MediaCreationTool.bat to ensure basic functionality is preserved.

### CI/CD Integration
Include these tests in your continuous integration pipeline:

```yaml
# Example GitHub Actions step
- name: Test MediaCreationTool.bat basic functionality
  run: |
    pwsh -File test-basic-functionality.ps1
  shell: pwsh
```

### Pre-deployment Verification
Use before deploying or distributing MediaCreationTool.bat to ensure it's accessible and properly formatted.

## Troubleshooting

### Common Issues

**Script not found**: Ensure the test is run from the same directory as MediaCreationTool.bat

**Permission errors**: Run with appropriate permissions, especially on Windows

**Timeout issues**: Increase timeout values if testing on slow systems

**PowerShell execution policy**: You may need to adjust PowerShell execution policy:
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```

## Contributing

When modifying MediaCreationTool.bat, ensure these tests continue to pass. If you add new features that should be tested, consider extending these test scripts or creating additional ones.

## Future Enhancements

Potential improvements for these tests:
- Add tests for specific command-line parameters
- Verify GUI mode functionality
- Test specific Windows version scenarios
- Add integration with testing frameworks
- Include performance benchmarking

---

**Note**: For comprehensive functionality testing, always test MediaCreationTool.bat manually in a real Windows environment with the specific use cases you intend to support.