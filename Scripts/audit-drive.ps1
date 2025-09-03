# =====================================================================
# audit-drive.ps1
# Prime TS BD Automation – Drive Audit Script
# Walks the Master Drive folder tree and outputs JSON with all files/folders
# =====================================================================

# Root of your Master State Google Drive
$driveRoot = "H:\My Drive\Prime TS BD Automation (BD IntelliRepo)"

# Where to save the audit results
$outputJson = "C:\Prime-TS-BD-Automation-Master-Inventory-and-Timeline-Package\inventory\Drive_Audit.json"

# Collect all files and folders recursively
$items = Get-ChildItem -Path $driveRoot -Recurse -Force | ForEach-Object {
    [PSCustomObject]@{
        Path         = $_.FullName
        Type         = if ($_.PSIsContainer) { "Folder" } else { "File" }
        SizeKB       = if ($_.PSIsContainer) { 0 } else { [Math]::Round($_.Length / 1KB,2) }
        LastModified = $_.LastWriteTime
    }
}

# Convert to JSON
$items | ConvertTo-Json -Depth 5 | Out-File -FilePath $outputJson -Encoding UTF8

Write-Host "✅ Drive audit complete. Results saved to $outputJson"
