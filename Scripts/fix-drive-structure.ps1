# =====================================================================
# Prime TS BD Automation – fix-drive-structure.ps1
# Baseline skeleton to enforce folder hierarchy and prep for artifact moves
# Root Path: H:\My Drive\Prime TS BD Automation (BD IntelliRepo)
# =====================================================================

# 1. Set root
$root = "H:\My Drive\Prime TS BD Automation (BD IntelliRepo)"
Set-Location $root

# 2. Ensure core engine folders exist
$engineFolders = @(
    "Engine 1 – Scraper\References",
    "Engine 1 – Scraper\Setup Guides",
    "Engine 1 – Scraper\Configurations",
    "Engine 1 – Scraper\Workflows & Scripts",
    "Engine 1 – Scraper\Data Exports",
    "Engine 1 – Scraper\Test Data",

    "Engine 2 – Program Mapping\Strategy Docs",
    "Engine 2 – Program Mapping\Credibility Docs",
    "Engine 2 – Program Mapping\Competitive Intel",
    "Engine 2 – Program Mapping\Data (Placements)",

    "Engine 3 – Org Chart\Strategy & Design",
    "Engine 3 – Org Chart\Program-Specific Intel",
    "Engine 3 – Org Chart\References",
    "Engine 3 – Org Chart\Data (Placements)",
    "Engine 3 – Org Chart\Data Processing Scripts",

    "Engine 4 – Playbook\Master Playbook",
    "Engine 4 – Playbook\Strategy Guides",
    "Engine 4 – Playbook\Agent Outputs",

    "Engine 5 – Scoring\Design & Specs",
    "Engine 5 – Scoring\Reference Reports",

    "🔧 Architecture & Planning",
    "🤖 Agent Prompts",
    "📊 Trackers & Sheets",
    "📁 External References",
    "📁 External Templates",
    "Archive",
    "Unsorted"
)

foreach ($folder in $engineFolders) {
    $fullPath = Join-Path $root $folder
    if (-not (Test-Path $fullPath)) {
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
        Write-Host "✅ Created: $fullPath"
    } else {
        Write-Host "✔️ Exists:  $fullPath"
    }
}

# 3. Move non-canonical files into Unsorted for review
$allExpected = $engineFolders | ForEach-Object { Join-Path $root $_ }
$allFiles = Get-ChildItem -Path $root -File -Recurse

foreach ($file in $allFiles) {
    $parent = Split-Path $file.FullName -Parent
    if ($allExpected -notcontains $parent) {
        $unsortedPath = Join-Path $root "Unsorted" $file.Name
        Move-Item $file.FullName $unsortedPath -Force
        Write-Host "⚠️ Moved to Unsorted: $($file.Name)"
    }
}

# 4. Hooks for artifact renames/moves (expand later)
# Example:
# Move-Item "$root\Unsorted\Apify Actor Input - Fort Meade.json" `
#          "$root\Engine 1 – Scraper\Workflows & Scripts\FortMeade_ApifyInput.json" -Force

Write-Host "`n=== Baseline Drive Structure Fix Completed ==="
