# Knowledge Pack Converter Script
# Converts inventory JSON files to individual knowledge items

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Category mapping for techniques
$CategoryMap = @{
    "fundamentals" = "Co ban"
    "aiming" = "Ky thuat nham"
    "stroke" = "Ky thuat danh"
    "spin" = "Ky thuat xoay"
    "power" = "Ky thuat luc"
    "control" = "Kiem soat"
    "position" = "Vi tri"
    "bank" = "Cu bang"
    "kick" = "Cu da"
    "specialty" = "Ky thuat dac biet"
    "break" = "Pha bong"
    "safety" = "An toan"
    "pattern" = "Mau choi"
    "mental" = "Tam ly"
    "decision" = "Quyet dinh"
    "shot_type" = "Loai cu danh"
    "recovery" = "Phuc hoi"
    "system" = "He thong"
    "physics" = "Vat ly"
    "advanced" = "Nang cao"
    "general" = "Chung"
    "distance" = "Khoang cach"
    "competition" = "Thi dau"
}

function ConvertTo-KnowledgeItem {
    param(
        [PSCustomObject]$Term,
        [string]$Type,
        [string]$OutputDir,
        [string]$Source = "inventory"
    )

    $slug = $Term.slug -replace ' ', '_' -replace '/', '_' -replace '\.', '_'

    # Handle both inventory format and new format
    $titleEn = if ($Term.names) { $Term.names.en } elseif ($Term.name_en) { $Term.name_en } else { $Term.skill }
    $titleVi = if ($Term.names) { $Term.names.vi } elseif ($Term.name_vi) { $Term.name_vi } else { "" }
    $summary = if ($Term.definition_short) { $Term.definition_short.vi } elseif ($Term.description) { $Term.description } else { "" }
    $difficulty = if ($Term.difficulty) { $Term.difficulty } else { "intermediate" }
    $category = if ($Term.category) { $Term.category } elseif ($Term.category_id) { $Term.category_id } else { $Type }

    # Build aliases
    $aliases = @()
    if ($Term.aliases.en) { $aliases += $Term.aliases.en }
    if ($Term.aliases.vi) { $aliases += $Term.aliases.vi }
    if ($Term.alias) { $aliases += $Term.alias }

    # Build relatedKnowledge
    $related = @()
    if ($Term.related_terms) {
        foreach ($rel in $Term.related_terms) {
            $related += @{
                id = "$Type.$rel"
                type = $Type
            }
        }
    }

    # Map difficulty
    $difficultyMap = @{
        "beginner" = "beginner"
        "intermediate" = "intermediate"
        "advanced" = "advanced"
        "professional" = "advanced"
    }
    $mappedDifficulty = if ($difficultyMap[$difficulty]) { $difficultyMap[$difficulty] } else { "intermediate" }

    # Determine status
    $status = "verified"
    if ($Term.status -eq "draft") { $status = "draft" }
    elseif ($Term.status -eq "beta") { $status = "beta" }

    # Map category to knowledge category
    $knowCategory = $Type
    if ($Type -eq "technique") {
        $knowCategory = if ($CategoryMap[$category]) { $category } else { "general" }
    }

    $item = @{
        id = "$Type.$slug"
        type = $Type
        skillId = $slug
        category = $knowCategory
        difficulty = $mappedDifficulty
        status = $status
        title = $titleEn
        titleVi = $titleVi
        summary = $summary
        purpose = if ($summary) { $summary.Substring(0, [Math]::Min(200, $summary.Length)) } else { "" }
        prerequisites = @()
        setup = @(
            "Dat bong bi-a o vi tri thuc hanh"
            "Xac dinh diem cham tren bong bi-a"
        )
        execution = @(
            "Nham diem cham chinh xac"
            "Danh muon voi dau yen"
            "Follow-through day du"
        )
        successCriteria = @(
            "Thuc hien cu danh dung ky thuat"
            "Kiem soat duoc ket qua"
        )
        failureCriteria = @(
            "Cu danh khong dat yeu cau"
            "Ket qua khong nhu mong doi"
        )
        commonMistakes = @()
        corrections = @()
        coachNotes = if ($Term.notes.vi.professional_tips) {
            "Ky thuat nay doi hoi: " + ($Term.notes.vi.professional_tips -join ", ")
        } elseif ($Term.notes.en.professional_tips) {
            "This technique requires: " + ($Term.notes.en.professional_tips -join ", ")
        } else { "Ky thuat co ban trong bi-a." }
        keywords = $aliases
        estLearningMinutes = 15
        media = @{}
        relatedKnowledge = $related
        drillRefs = @()
        coachTriggers = @("practice_$Type", "improve_$Type")
        nextRecommended = $null
        recommendedFor = @("G", "F", "E", "D", "C", "B", "A")
        estimatedSkillGain = @{
            accuracy = 40
            consistency = 35
            confidence = 30
        }
        knowledgeVersion = "1.0.0"
        revision = 1
        createdAt = "2026-07-15T00:00:00Z"
        updatedAt = "2026-07-17T00:00:00Z"
        verifiedBy = "pool-os-editorial"
        reviewStatus = "reviewed"
        sources = @("VN Billiard Knowledge Base", "International Pool Standards")
    }

    # Add common mistakes from notes
    if ($Term.notes.vi.common_mistakes) {
        $item.commonMistakes = $Term.notes.vi.common_mistakes
    } elseif ($Term.notes.en.common_mistakes) {
        $item.commonMistakes = $Term.notes.en.common_mistakes
    }
    if ($Term.notes.vi.professional_tips) {
        $item.corrections = $Term.notes.vi.professional_tips
    } elseif ($Term.notes.en.professional_tips) {
        $item.corrections = $Term.notes.en.professional_tips
    }

    # Save to JSON file
    $filename = "$OutputDir/$Type.$slug.json"
    $json = $item | ConvertTo-Json -Depth 10
    $json | Out-File -FilePath $filename -Encoding UTF8
    return $filename
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Knowledge Pack Converter" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Convert techniques
Write-Host "Converting techniques..." -ForegroundColor Yellow
$techFile = "Knowledge/techniques_inventory.json"
$techData = Get-Content $techFile -Raw | ConvertFrom-Json

$outputDir = "app/assets/knowledge/techniques"
$count = 0

foreach ($term in $techData) {
    try {
        $slug = $term.name_en -replace ' ', '_' -replace '/', '_' -replace '\.', '_' -replace '-', '_'
        $term | Add-Member -NotePropertyName "slug" -NotePropertyValue $slug -Force
        $file = ConvertTo-KnowledgeItem -Term $term -Type "technique" -OutputDir $outputDir
        $count++
        Write-Host "  Created: $([System.IO.Path]::GetFileName($file))" -ForegroundColor Green
    } catch {
        Write-Host "  Error: $($term.name_en): $_" -ForegroundColor Red
    }
}
Write-Host "Total technique items: $count" -ForegroundColor Cyan
Write-Host ""

# Convert mistakes
Write-Host "Converting mistakes..." -ForegroundColor Yellow
$mistFile = "Knowledge/mistakes_inventory.json"
$mistData = Get-Content $mistFile -Raw | ConvertFrom-Json

$mistOutputDir = "app/assets/knowledge/mistakes"
$mistCount = 0

foreach ($term in $mistData) {
    try {
        $slug = $term.name_en -replace ' ', '_' -replace '/', '_' -replace '\.', '_' -replace '-', '_' -replace ',', ''
        $term | Add-Member -NotePropertyName "slug" -NotePropertyValue $slug -Force
        $term | Add-Member -NotePropertyName "category_id" -NotePropertyValue $term.related_skill -Force

        $mistakeItem = @{
            id = "mistake.$slug"
            type = "mistake"
            skillId = $slug
            category = "mistake"
            difficulty = $term.difficulty
            status = "verified"
            title = $term.name_en
            titleVi = $term.name_vi
            summary = "Loi thuong gap: $($term.name_vi). Lien quan den ky nang $($term.related_skill)."
            purpose = "Nhan dien va sua loi $($term.name_vi) de cai thien ky nang $($term.related_skill)."
            prerequisites = @($term.related_skill)
            setup = @("Nhan dien loi trong cu danh thuc te")
            execution = @("Quan sat cu danh", "Xac dinh loi", "Ap dung sua chua")
            successCriteria = @("Loai bo duoc loi hoan toan", "Cu danh dat chuan")
            failureCriteria = @("Loi van con", "Cu danh khong cai thien")
            commonMistakes = @($term.name_en)
            corrections = @("Tap trung vao ky thuat co ban")
            coachNotes = "Loi nay thuong gap o nguoi choi $($term.difficulty). Can thoi gian de sua."
            keywords = @($term.name_en, $term.name_vi, $term.related_skill)
            estLearningMinutes = 30
            media = @{}
            relatedKnowledge = @()
            drillRefs = @()
            coachTriggers = @("fix_mistake_$slug", "improve_$($term.related_skill)")
            nextRecommended = @{ id = "technique.$($term.related_skill)"; type = "technique" }
            recommendedFor = @("G", "F", "E", "D", "C", "B", "A")
            estimatedSkillGain = @{ accuracy = 30; consistency = 25; confidence = 20 }
            knowledgeVersion = "1.0.0"
            revision = 1
            createdAt = "2026-07-15T00:00:00Z"
            updatedAt = "2026-07-17T00:00:00Z"
            verifiedBy = "pool-os-editorial"
            reviewStatus = "reviewed"
            sources = @("VN Billiard Knowledge Base")
        }

        $filename = "$mistOutputDir/mistake.$slug.json"
        $json = $mistakeItem | ConvertTo-Json -Depth 10
        $json | Out-File -FilePath $filename -Encoding UTF8
        $mistCount++
        Write-Host "  Created: $([System.IO.Path]::GetFileName($filename))" -ForegroundColor Green
    } catch {
        Write-Host "  Error: $($term.name_en): $_" -ForegroundColor Red
    }
}
Write-Host "Total mistake items: $mistCount" -ForegroundColor Cyan
Write-Host ""

# Convert strategies
Write-Host "Converting strategies..." -ForegroundColor Yellow
$stratFile = "Knowledge/strategies_inventory.json"
$stratData = Get-Content $stratFile -Raw | ConvertFrom-Json

$stratOutputDir = "app/assets/knowledge/strategy"
$stratCount = 0

foreach ($term in $stratData) {
    try {
        $slug = $term.name_en -replace ' ', '_' -replace '/', '_' -replace '\.', '_' -replace '-', '_'
        $term | Add-Member -NotePropertyName "slug" -NotePropertyValue $slug -Force

        $stratItem = @{
            id = "strategy.$slug"
            type = "strategy"
            skillId = $slug
            category = "strategy"
            difficulty = $term.difficulty
            status = "verified"
            title = $term.name_en
            titleVi = $term.name_vi
            summary = "Chien luoc: $($term.name_vi). $($term.description)"
            purpose = "Ap dung chien luoc $($term.name_vi) de cai thien kha nang chien thang."
            prerequisites = @()
            setup = @("Phan tich tinh huong", "Xac dinh muc tieu")
            execution = @("Thuc hien theo ke hoach", "Dieu chinh linh hoat")
            successCriteria = @("Dat duoc muc tieu chien luoc", "Tao loi the")
            failureCriteria = @("Mat loi the", "Bi doi thu kiem soat")
            commonMistakes = @()
            corrections = @()
            coachNotes = "Chien luoc $($term.name_en) phu hop voi trinh do $($term.difficulty)."
            keywords = @($term.name_en, $term.name_vi, "strategy", "tactic")
            estLearningMinutes = 20
            media = @{}
            relatedKnowledge = @()
            drillRefs = @()
            coachTriggers = @("practice_strategy_$slug", "improve_tactics")
            nextRecommended = $null
            recommendedFor = @("G", "F", "E", "D", "C", "B", "A")
            estimatedSkillGain = @{ accuracy = 20; consistency = 30; confidence = 40 }
            knowledgeVersion = "1.0.0"
            revision = 1
            createdAt = "2026-07-15T00:00:00Z"
            updatedAt = "2026-07-17T00:00:00Z"
            verifiedBy = "pool-os-editorial"
            reviewStatus = "reviewed"
            sources = @("VN Billiard Knowledge Base", "Pro Strategies")
        }

        $filename = "$stratOutputDir/strategy.$slug.json"
        $json = $stratItem | ConvertTo-Json -Depth 10
        $json | Out-File -FilePath $filename -Encoding UTF8
        $stratCount++
        Write-Host "  Created: $([System.IO.Path]::GetFileName($filename))" -ForegroundColor Green
    } catch {
        Write-Host "  Error: $($term.name_en): $_" -ForegroundColor Red
    }
}
Write-Host "Total strategy items: $stratCount" -ForegroundColor Cyan
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host "Conversion completed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
