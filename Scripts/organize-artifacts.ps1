param()

$auditPath = "Drive_Audit.json"
$logPath = "organize-log.txt"
$folders = @("scraper","mapping","orgchart","playbook","scoring")

foreach ($f in $folders) {
    if (-not (Test-Path $f)) {
        New-Item -ItemType Directory -Path $f | Out-Null
    }
}

if (Test-Path $auditPath) {
    Move-Item $auditPath "scraper\scraper__drive-audit.json"
    Add-Content $logPath "Moved $auditPath -> scraper\scraper__drive-audit.json"
}
