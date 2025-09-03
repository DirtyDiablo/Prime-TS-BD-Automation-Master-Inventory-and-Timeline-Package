# =====================================================================
# Prime TS BD Automation – audit-drive.ps1
# Traverse target drives and export folder/file inventories
# Targets:
#   H:\Shared drives\PrimeTS Knowledge Base
#   H:\My Drive\Prime TS BD Automation (BD IntelliRepo)
# Outputs:
#   Drive_Audit.json
#   Drive_Audit.xlsx
#   audit-drive.log
# =====================================================================

param()

$targets = @(
    "H:\\Shared drives\\PrimeTS Knowledge Base",
    "H:\\My Drive\\Prime TS BD Automation (BD IntelliRepo)"
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$outputDir = Split-Path -Parent $scriptDir
$logPath   = Join-Path $outputDir 'audit-drive.log'
$jsonPath  = Join-Path $outputDir 'Drive_Audit.json'
$excelPath = Join-Path $outputDir 'Drive_Audit.xlsx'

Start-Transcript -Path $logPath -Force | Out-Null

$items = @()
foreach ($target in $targets) {
    if (Test-Path $target) {
        Get-ChildItem -Path $target -Recurse -Force | ForEach-Object {
            $items += [PSCustomObject]@{
                Path        = $_.FullName
                ItemType    = if ($_.PSIsContainer) { 'Folder' } else { 'File' }
                SizeBytes   = if ($_.PSIsContainer) { 0 } else { $_.Length }
                LastModified = $_.LastWriteTime
            }
            Write-Output ("{0}`t{1}`t{2}`t{3}" -f $_.FullName, $items[-1].ItemType, $items[-1].SizeBytes, $items[-1].LastModified)
        }
    } else {
        Write-Warning "Missing: $target"
    }
}

$items | ConvertTo-Json -Depth 5 | Out-File $jsonPath -Encoding UTF8

if (Get-Module -ListAvailable -Name ImportExcel) {
    $items | Export-Excel -Path $excelPath -WorksheetName 'Audit' -AutoSize -Force
} else {
    Write-Warning 'ImportExcel module not found. JSON output only.'
}

Stop-Transcript | Out-Null