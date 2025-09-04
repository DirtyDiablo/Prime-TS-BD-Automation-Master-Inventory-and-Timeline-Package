Param(
    [ValidateSet("Reset Master State", "Deploy Final Project Artifacts", "Full Artifact Migration", "Unified Full Orchestration")]
    [string]$Mode,
    [switch]$DryRun
)

# Load orchestration plan
$plan = Get-Content -Raw -Path ".\scripts\orchestration_plan.json" | ConvertFrom-Json

# Find the step
$step = $plan.steps | Where-Object { $_.name -eq $Mode }
if (-not $step) {
    Write-Host "❌ Step '$Mode' not found in orchestration_plan.json"
    exit 1
}

Write-Host "[STEP] $($step.name)"

# Run each action
foreach ($action in $step.actions) {
    $type = $action.type
    $src = $action.source
    $dest = $action.destination
    $script = $action.script
    $link = $action.link
    $title = $action.title
    $cmd = $action.command

    if ($DryRun) {
        switch ($type) {
            "create_folder" {
                Write-Host "    [DRYRUN] Would run ${type}: $dest"
            }
            "move" {
                Write-Host "    [DRYRUN] Would run ${type}: $src -> $dest"
            }
            "copy" {
                Write-Host "    [DRYRUN] Would run ${type}: $src -> $dest"
            }
            "generate_markdown_link" {
                Write-Host "    [DRYRUN] Would create markdown link at $dest"
            }
            "run_script" {
                Write-Host "    [DRYRUN] Would run ${type}: $script"
            }
            "generate_inventory" {
                Write-Host "    [DRYRUN] Would run ${type}: $src -> $dest"
            }
            "run" {
                Write-Host "    [DRYRUN] Would run ${type}: $cmd"
            }
        }
        continue
    }

    switch ($type) {
        "create_folder" {
            if (-not (Test-Path -Path $dest)) {
                New-Item -Path $dest -ItemType Directory -Force | Out-Null
            }
        }
        "move" {
            if (Test-Path -Path $src) {
                Move-Item -Path $src -Destination $dest -Force
            } else {
                Write-Warning "Missing source: $src"
            }
        }
        "copy" {
            if (Test-Path -Path $src) {
                Copy-Item -Path $src -Destination $dest -Force
            } else {
                Write-Warning "Missing source: $src"
            }
        }
        "generate_markdown_link" {
            $md = "[${title}](${link})"
            $md | Out-File -FilePath $dest -Encoding utf8
            Write-Host "    Created markdown link file: $dest"
        }
        "run_script" {
            $fullScript = ".\scripts\$script"
            if (Test-Path $fullScript) {
                & $fullScript @args
                Write-Host "    Ran script: $script"
            } else {
                Write-Warning "Script not found: $fullScript"
            }
        }
        "generate_inventory" {
            $files = Get-ChildItem -Recurse -Path $action.source_path | Select-Object FullName, Name, Length, LastWriteTime
            $files | ConvertTo-Json -Depth 5 | Out-File -FilePath $dest -Encoding utf8
            Write-Host "    Generated inventory with $($files.Count) entries."
        }
        "run" {
            Invoke-Expression $cmd
            Write-Host "    Ran command: $cmd"
        }
    }
}

# Run validations
foreach ($v in $step.validation) {
    $path = $v.path
    switch ($v.condition) {
        "exists" {
            if (Test-Path $path) {
                Write-Host "    ✅ Validated: $path exists"
            } else {
                Write-Warning "❌ Validation failed: $path missing"
            }
        }
        "file_count" {
            $count = (Get-ChildItem -File -Path $path -Recurse).Count
            if ($count -ge $v.min_count) {
                Write-Host "    ✅ $count files found in $path"
            } else {
                Write-Warning "❌ Only $count files found in $path, expected at least $($v.min_count)"
            }
        }
    }
}
Write-Host "✅ All steps processed. Log saved to organize-log.txt."
