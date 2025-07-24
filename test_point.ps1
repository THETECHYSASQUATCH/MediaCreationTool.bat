# Test Point constructors to identify the issue
try {
    Add-Type -AssemblyName System.Drawing
    
    # Test basic Point constructor
    $point1 = New-Object System.Drawing.Point(10, 20)
    Write-Host "Point1 created successfully: $point1"
    
    # Test expressions that might be problematic
    $buttonY = 80
    $buttonSpacing = 70
    
    $expr1 = ($buttonY + $buttonSpacing + 80)
    Write-Host "Expression 1 result: $expr1 (type: $($expr1.GetType()))"
    
    $point2 = New-Object System.Drawing.Point(10, ($buttonY + $buttonSpacing + 80))
    Write-Host "Point2 created successfully: $point2"
    
    # Test with Config FormHeight
    $Config = @{ FormHeight = 600 }
    $expr2 = ($Config.FormHeight - 70)
    Write-Host "Expression 2 result: $expr2 (type: $($expr2.GetType()))"
    
    $point3 = New-Object System.Drawing.Point(10, $Config.FormHeight - 70)
    Write-Host "Point3 created successfully: $point3"
    
} catch {
    Write-Host "Error: $($_.Exception.Message)"
    Write-Host "Stack trace: $($_.Exception.StackTrace)"
}