# Knowledge Pack Converter - Using .NET for Unicode
$ErrorActionPreference = "Stop"

# Use .NET to handle UTF-8 properly
Add-Type -AssemblyName System.Text.Encoding

function Read-JsonUtf8 {
    param([string]$Path)
    $content = [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
    return $content | ConvertFrom-Json
}

# Convert techniques
Write-Host "Converting techniques..." -ForegroundColor Yellow
$techData = Read-JsonUtf8 -Path "Knowledge/techniques_inventory.json"

$techDir = "app/assets/knowledge/techniques"
if (-not (Test-Path $techDir)) { New-Item -ItemType Directory -Path $techDir | Out-Null }

$count = 0
foreach ($term in $techData) {
    $nameEn = $term.name_en
    $nameVi = $term.name_vi
    $category = $term.category
    $slug = $nameEn -replace ' ', '_' -replace '/', '_' -replace '\.', '_' -replace '-', '_'
    
    $item = @{
        id = "technique.$slug"
        type = "technique"
        skillId = $slug
        category = $category
        difficulty = $term.difficulty
        status = "verified"
        title = $nameEn
        titleVi = $nameVi
        summary = "Ky thuat: $nameVi"
        purpose = "Hoc va thuc hanh ky thuat $nameVi"
        prerequisites = @()
        setup = @("Dat bong bi-a o vi tri thuc hanh", "Xac dinh diem cham tren bong bi-a")
        execution = @("Nham diem cham chinh xac", "Danh muon voi dau yen", "Follow-through day du")
        successCriteria = @("Thuc hien cu danh dung ky thuat", "Kiem soat duoc ket qua")
        failureCriteria = @("Cu danh khong dat yeu cau", "Ket qua khong nhu mong")
        commonMistakes = @()
        corrections = @()
        coachNotes = "Ky thuat $nameEn phu hop voi trinh do $($term.difficulty)."
        keywords = @($nameEn, $nameVi)
        estLearningMinutes = 15
        media = @{}
        relatedKnowledge = @()
        drillRefs = @()
        coachTriggers = @("practice_technique", "improve_technique")
        nextRecommended = $null
        recommendedFor = @("G", "F", "E", "D", "C", "B", "A")
        estimatedSkillGain = @{accuracy = 40; consistency = 35; confidence = 30}
        knowledgeVersion = "1.0.0"
        revision = 1
        createdAt = "2026-07-15T00:00:00Z"
        updatedAt = "2026-07-17T00:00:00Z"
        verifiedBy = "pool-os-editorial"
        reviewStatus = "reviewed"
        sources = @("VN Billiard Knowledge Base", "International Pool Standards")
    }
    
    $filename = "$techDir/technique.$slug.json"
    $json = $item | ConvertTo-Json -Depth 10
    [System.IO.File]::WriteAllText($filename, $json, [System.Text.Encoding]::UTF8)
    $count++
    Write-Host "  Created: technique.$slug.json" -ForegroundColor Green
}
Write-Host "Total technique items: $count" -ForegroundColor Cyan
Write-Host ""

# Convert mistakes
Write-Host "Converting mistakes..." -ForegroundColor Yellow
$mistData = Read-JsonUtf8 -Path "Knowledge/mistakes_inventory.json"

$mistDir = "app/assets/knowledge/mistakes"
if (-not (Test-Path $mistDir)) { New-Item -ItemType Directory -Path $mistDir | Out-Null }

$mistCount = 0
foreach ($term in $mistData) {
    $nameEn = $term.name_en
    $nameVi = $term.name_vi
    $skill = $term.related_skill
    $slug = $nameEn -replace ' ', '_' -replace '/', '_' -replace '\.', '_' -replace '-', '_' -replace ',', ''
    
    $item = @{
        id = "mistake.$slug"
        type = "mistake"
        skillId = $slug
        category = "mistake"
        difficulty = $term.difficulty
        status = "verified"
        title = $nameEn
        titleVi = $nameVi
        summary = "Loi thuong gap: $nameVi. Lien quan den ky nang $skill."
        purpose = "Nhan dien va sua loi $nameVi de cai thien ky nang $skill."
        prerequisites = @($skill)
        setup = @("Nhan dien loi trong cu danh thuc te")
        execution = @("Quan sat cu danh", "Xac dinh loi", "Ap dung sua chua")
        successCriteria = @("Loai bo duoc loi hoan toan", "Cu danh dat chuan")
        failureCriteria = @("Loi van con", "Cu danh khong cai thien")
        commonMistakes = @($nameEn)
        corrections = @("Tap trung vao ky thuat co ban")
        coachNotes = "Loi nay thuong gap o nguoi choi $($term.difficulty). Can thoi gian de sua."
        keywords = @($nameEn, $nameVi, $skill)
        estLearningMinutes = 30
        media = @{}
        relatedKnowledge = @()
        drillRefs = @()
        coachTriggers = @("fix_mistake_$slug", "improve_$skill")
        nextRecommended = @{id = "technique.$skill"; type = "technique"}
        recommendedFor = @("G", "F", "E", "D", "C", "B", "A")
        estimatedSkillGain = @{accuracy = 30; consistency = 25; confidence = 20}
        knowledgeVersion = "1.0.0"
        revision = 1
        createdAt = "2026-07-15T00:00:00Z"
        updatedAt = "2026-07-17T00:00:00Z"
        verifiedBy = "pool-os-editorial"
        reviewStatus = "reviewed"
        sources = @("VN Billiard Knowledge Base")
    }
    
    $filename = "$mistDir/mistake.$slug.json"
    $json = $item | ConvertTo-Json -Depth 10
    [System.IO.File]::WriteAllText($filename, $json, [System.Text.Encoding]::UTF8)
    $mistCount++
    Write-Host "  Created: mistake.$slug.json" -ForegroundColor Green
}
Write-Host "Total mistake items: $mistCount" -ForegroundColor Cyan
Write-Host ""

# Convert strategies
Write-Host "Converting strategies..." -ForegroundColor Yellow
$stratData = Read-JsonUtf8 -Path "Knowledge/strategies_inventory.json"

$stratDir = "app/assets/knowledge/strategy"
if (-not (Test-Path $stratDir)) { New-Item -ItemType Directory -Path $stratDir | Out-Null }

$stratCount = 0
foreach ($term in $stratData) {
    $nameEn = $term.name_en
    $nameVi = $term.name_vi
    $desc = $term.description
    $slug = $nameEn -replace ' ', '_' -replace '/', '_' -replace '\.', '_' -replace '-', '_'
    
    $item = @{
        id = "strategy.$slug"
        type = "strategy"
        skillId = $slug
        category = "strategy"
        difficulty = $term.difficulty
        status = "verified"
        title = $nameEn
        titleVi = $nameVi
        summary = "Chien luoc: $nameVi. $desc"
        purpose = "Ap dung chien luoc $nameVi de cai thien kha nang chien thang."
        prerequisites = @()
        setup = @("Phan tich tinh huong", "Xac dinh muc tieu")
        execution = @("Thuc hien theo ke hoach", "Dieu chinh linh hoat")
        successCriteria = @("Dat duoc muc tieu chien luoc", "Tao loi the")
        failureCriteria = @("Mat loi the", "Bi doi thu kiem soat")
        commonMistakes = @()
        corrections = @()
        coachNotes = "Chien luoc $nameEn phu hop voi trinh do $($term.difficulty)."
        keywords = @($nameEn, $nameVi, "strategy", "tactic")
        estLearningMinutes = 20
        media = @{}
        relatedKnowledge = @()
        drillRefs = @()
        coachTriggers = @("practice_strategy_$slug", "improve_tactics")
        nextRecommended = $null
        recommendedFor = @("G", "F", "E", "D", "C", "B", "A")
        estimatedSkillGain = @{accuracy = 20; consistency = 30; confidence = 40}
        knowledgeVersion = "1.0.0"
        revision = 1
        createdAt = "2026-07-15T00:00:00Z"
        updatedAt = "2026-07-17T00:00:00Z"
        verifiedBy = "pool-os-editorial"
        reviewStatus = "reviewed"
        sources = @("VN Billiard Knowledge Base", "Pro Strategies")
    }
    
    $filename = "$stratDir/strategy.$slug.json"
    $json = $item | ConvertTo-Json -Depth 10
    [System.IO.File]::WriteAllText($filename, $json, [System.Text.Encoding]::UTF8)
    $stratCount++
    Write-Host "  Created: strategy.$slug.json" -ForegroundColor Green
}
Write-Host "Total strategy items: $stratCount" -ForegroundColor Cyan
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host "Conversion completed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
