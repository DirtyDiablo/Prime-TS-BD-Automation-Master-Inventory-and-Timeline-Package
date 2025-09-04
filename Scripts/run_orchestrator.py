Param(
    [ValidateSet("Reset Master State", "Deploy Final Project Artifacts")]
    [string]$Mode,
    [switch]$DryRun
)

$planPath = Join-Path $PSScriptRoot "orchestration_plan.json"
if (-not (Test-Path $planPath)) {
    Write-Error "❌ orchestration_plan.json not found"
    exit 1
}

$plan = Get-Content $planPath -Raw | ConvertFrom-Json
$trigger = $plan.steps
$logPath = Join-Path $PSScriptRoot "organize-log.txt"
Add-Content $logPath "\n--- RUN START $(Get-Date -Format u) | Mode=$Mode | DryRun=$($DryRun.IsPresent) ---\n"

foreach ($step in $trigger) {
    Write-Host "[STEP] $($step.name)" -ForegroundColor Cyan
    Add-Content $logPath "[STEP] $($step.name)"

    foreach ($action in $step.actions) {
        $type = $action.type
        $src = $action.source
        $dest = $action.destination
        $path = $action.path
        $script = $action.script
        $args = $action.args
        $cmd = $action.command

        if ($DryRun) {
            Write-Host "    [DRYRUN] Would run $type: $src → $dest" -ForegroundColor Yellow
            Add-Content $logPath "    DRYRUN: $type $src → $dest"
            continue
        }

        switch ($type) {
            "create_folder" {
                if (-not (Test-Path $path)) {
                    New-Item -Path $path -ItemType Directory | Out-Null
                    Write-Host "    Created folder: $path"
                    Add-Content $logPath "    Created folder: $path"
                }
            }
            "move" {
                Move-Item -Path $src -Destination $dest -Force
                Write-Host "    Moved: $src → $dest"
                Add-Content $logPath "    Moved: $src → $dest"
            }
            "copy" {
                Copy-Item -Path $src -Destination $dest -Force
                Write-Host "    Copied: $src → $dest"
                Add-Content $logPath "    Copied: $src → $dest"
            }
            "run_script" {
                $fullScript = Join-Path $PSScriptRoot $script
                & $fullScript @args
                Write-Host "    Ran script: $script"
                Add-Content $logPath "    Ran script: $script"
            }
            "generate_inventory" {
                $files = Get-ChildItem -Path $action.source_path -Recurse -File
                $inventory = @()
                foreach ($f in $files) {
                    $record = [PSCustomObject]@{
                        artifact_name = $f.Name
                        engine = ($f.FullName -split "Engine \d – ")[1] -split "\\" | Select-Object -First 1
                        drive_path = $f.FullName
                        integration_status = "Live"
                        version = "1.0"
                        purpose = "Auto-generated"
                        integration_usage = "Sync"
                    }
                    $inventory += $record
                }
                $jsonPath = $action.destination
                $inventory | ConvertTo-Json -Depth 4 | Set-Content -Path $jsonPath -Encoding UTF8
                Write-Host "    Generated inventory with $($inventory.Count) entries."
                Add-Content $logPath "    Generated inventory with $($inventory.Count) entries."
            }
            "run" {
                Invoke-Expression $cmd
                Write-Host "    Ran command: $cmd"
                Add-Content $logPath "    Ran command: $cmd"
            }
            default {
                Write-Warning "    Unknown action type: $type"
                Add-Content $logPath "    Skipped unknown type: $type"
            }
        }
    }

    foreach ($v in $step.validation) {
        switch ($v.condition) {
            "exists" {
                if (Test-Path $v.path) {
                    Write-Host "    ✅ Validated: $($v.path) exists"
                    Add-Content $logPath "    ✅ Validated: $($v.path) exists"
                } else {
                    Write-Warning "    ❌ Validation failed: $($v.path) missing"
                    Add-Content $logPath "    ❌ Validation failed: $($v.path) missing"
                }
            }
            "file_count" {
                $count = (Get-ChildItem -Path $v.path -File).Count
                if ($count -ge $v.min_count) {
                    Write-Host "    ✅ $count files found in $($v.path)"
                    Add-Content $logPath "    ✅ $count files in $($v.path)"
                } else {
                    Write-Warning "    ❌ Only $count files in $($v.path), expected at least $($v.min_count)"
                    Add-Content $logPath "    ❌ Only $count files in $($v.path)"
                }
            }
            default {
                Write-Host "    ⚠️ Validation type '$($v.condition)' not handled explicitly."
                Add-Content $logPath "    ⚠️ Skipped validation type: $($v.condition)"
            }
        }
    }
}

Write-Host "✅ All steps processed. Log saved to organize-log.txt." -ForegroundColor Green
Add-Content $logPath "--- RUN END $(Get-Date -Format u) ---\n"
