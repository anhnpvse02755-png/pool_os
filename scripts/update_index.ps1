# Update index.json with all knowledge items

$ErrorActionPreference = "Stop"

# Get all knowledge files
$knowledgeDir = "app/assets/knowledge"

$indexItems = @()

# Get spin items
$spinDir = "$knowledgeDir/spin"
if (Test-Path $spinDir) {
    Get-ChildItem $spinDir -Filter "*.json" | ForEach-Object {
        $relativePath = "spin/" + $_.Name
        $indexItems += $relativePath
    }
}

# Get technique items
$techDir = "$knowledgeDir/techniques"
if (Test-Path $techDir) {
    Get-ChildItem $techDir -Filter "*.json" | ForEach-Object {
        $relativePath = "techniques/" + $_.Name
        $indexItems += $relativePath
    }
}

# Get mistake items
$mistDir = "$knowledgeDir/mistakes"
if (Test-Path $mistDir) {
    Get-ChildItem $mistDir -Filter "*.json" | ForEach-Object {
        $relativePath = "mistakes/" + $_.Name
        $indexItems += $relativePath
    }
}

# Get strategy items
$stratDir = "$knowledgeDir/strategy"
if (Test-Path $stratDir) {
    Get-ChildItem $stratDir -Filter "*.json" | ForEach-Object {
        $relativePath = "strategy/" + $_.Name
        $indexItems += $relativePath
    }
}

# Get equipment items
$equipDir = "$knowledgeDir/equipment"
if (Test-Path $equipDir) {
    Get-ChildItem $equipDir -Filter "*.json" | ForEach-Object {
        $relativePath = "equipment/" + $_.Name
        $indexItems += $relativePath
    }
}

# Get mental items
$mentalDir = "$knowledgeDir/mental"
if (Test-Path $mentalDir) {
    Get-ChildItem $mentalDir -Filter "*.json" | ForEach-Object {
        $relativePath = "mental/" + $_.Name
        $indexItems += $relativePath
    }
}

# Sort alphabetically
$indexItems = $indexItems | Sort-Object

# Save to index.json
$json = $indexItems | ConvertTo-Json
$json | Out-File -FilePath "$knowledgeDir/index.json" -Encoding UTF8

Write-Host "Updated index.json with $($indexItems.Count) items" -ForegroundColor Cyan
Write-Host ""
Write-Host "Summary by category:" -ForegroundColor Yellow
Write-Host "  Spin items: $(($indexItems | Where-Object { $_ -like 'spin/*' }).Count)"
Write-Host "  Technique items: $(($indexItems | Where-Object { $_ -like 'techniques/*' }).Count)"
Write-Host "  Mistake items: $(($indexItems | Where-Object { $_ -like 'mistakes/*' }).Count)"
Write-Host "  Strategy items: $(($indexItems | Where-Object { $_ -like 'strategy/*' }).Count)"
Write-Host "  Equipment items: $(($indexItems | Where-Object { $_ -like 'equipment/*' }).Count)"
Write-Host "  Mental items: $(($indexItems | Where-Object { $_ -like 'mental/*' }).Count)"
