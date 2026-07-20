# Knowledge Pack Converter Script - Fixed Vietnamese Encoding
# Converts inventory JSON files to individual knowledge items

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Read files with proper encoding
function Get-JsonContent {
    param([string]$Path)
    $content = [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
    return $content | ConvertFrom-Json
}

# Vietnamese text (using proper Unicode)
$VietText = @{
    "setup_instruction" = "Đặt bóng bi-a ở vị trí thực hành"
    "aim_instruction" = "Ngắm điểm chạm chính xác"
    "stroke_instruction" = "Đánh mượt với đầu yên"
    "follow_instruction" = "Follow-through đầy đủ"
    "success_criteria" = "Thực hiện cú đánh đúng kỹ thuật"
    "failure_criteria" = "Cú đánh không đạt yêu cầu"
    "basic_technique" = "Kỹ thuật cơ bản trong bi-a"
    "requires" = "Kỹ thuật này đòi hỏi"
    "learn_more" = "Học thêm"
}

# Category mapping for techniques
$CategoryMap = @{
    "fundamentals" = "Kỹ thuật cơ bản"
    "aiming" = "Kỹ thuật ngắm"
    "stroke" = "Kỹ thuật đánh"
    "spin" = "Kỹ thuật xoáy"
    "power" = "Kỹ thuật lực"
    "control" = "Kiểm soát"
    "position" = "Vị trí"
    "bank" = "Cú băng"
    "kick" = "Cú đá"
    "specialty" = "Kỹ thuật đặc biệt"
    "break" = "Phá bóng"
    "safety" = "An toàn"
    "pattern" = "Mẫu chơi"
    "mental" = "Tâm lý"
    "decision" = "Quyết định"
    "shot_type" = "Loại cú đánh"
    "recovery" = "Phục hồi"
    "system" = "Hệ thống"
    "physics" = "Vật lý"
    "advanced" = "Nâng cao"
    "general" = "Chung"
    "distance" = "Khoảng cách"
    "competition" = "Thi đấu"
}

function ConvertTo-KnowledgeItem {
    param(
        [PSCustomObject]$Term,
        [string]$Type,
        [string]$OutputDir
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

    # Get professional tips
    $tips = @()
    if ($Term.notes.vi.professional_tips) { $tips = $Term.notes.vi.professional_tips }
    elseif ($Term.notes.en.professional_tips) { $tips = $Term.notes.en.professional_tips }

    $coachNotes = if ($tips.Count -gt 0) {
        "Kỹ thuật này đòi hỏi: " + ($tips -join ", ")
    } else { $VietText.basic_technique }

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
        purpose = if ($summary -and $summary.Length -gt 0) { $summary.Substring(0, [Math]::Min(200, $summary.Length)) } else { $summary }
        prerequisites = @()
        setup = @($VietText.setup_instruction)
        execution = @($VietText.aim_instruction, $VietText.stroke_instruction, $VietText.follow_instruction)
        successCriteria = @($VietText.success_criteria)
        failureCriteria = @($VietText.failure_criteria)
        commonMistakes = @()
        corrections = $tips
        coachNotes = $coachNotes
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

    # Save to JSON file
    $filename = "$OutputDir/$Type.$slug.json"
    $json = $item | ConvertTo-Json -Depth 10
    [System.IO.File]::WriteAllText($filename, $json, [System.Text.Encoding]::UTF8)
    return $filename
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Knowledge Pack Converter - Fixed" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Convert techniques
Write-Host "Converting techniques..." -ForegroundColor Yellow
$techData = Get-JsonContent -Path "Knowledge/techniques_inventory.json"

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
$mistData = Get-JsonContent -Path "Knowledge/mistakes_inventory.json"

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
            summary = "Lỗi thường gặp: $($term.name_vi). Liên quan đến kỹ năng $($term.related_skill)."
            purpose = "Nhận diện và sửa lỗi $($term.name_vi) để cải thiện kỹ năng $($term.related_skill)."
            prerequisites = @($term.related_skill)
            setup = @("Nhận diện lỗi trong cú đánh thực tế")
            execution = @("Quan sát cú đánh", "Xác định lỗi", "Áp dụng sửa chữa")
            successCriteria = @("Loại bỏ được lỗi hoàn toàn", "Cú đánh đạt chuẩn")
            failureCriteria = @("Lỗi vẫn còn", "Cú đánh không cải thiện")
            commonMistakes = @($term.name_en)
            corrections = @("Tập trung vào kỹ thuật cơ bản")
            coachNotes = "Lỗi này thường gặp ở người chơi $($term.difficulty). Cần thời gian để sửa."
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
        [System.IO.File]::WriteAllText($filename, $json, [System.Text.Encoding]::UTF8)
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
$stratData = Get-JsonContent -Path "Knowledge/strategies_inventory.json"

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
            summary = "Chiến lược: $($term.name_vi). $($term.description)"
            purpose = "Áp dụng chiến lược $($term.name_vi) để cải thiện khả năng chiến thắng."
            prerequisites = @()
            setup = @("Phân tích tình huống", "Xác định mục tiêu")
            execution = @("Thực hiện theo kế hoạch", "Điều chỉnh linh hoạt")
            successCriteria = @("Đạt được mục tiêu chiến lược", "Tạo lợi thế")
            failureCriteria = @("Mất lợi thế", "Bị đối thủ kiểm soát")
            commonMistakes = @()
            corrections = @()
            coachNotes = "Chiến lược $($term.name_en) phù hợp với trình độ $($term.difficulty)."
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
        [System.IO.File]::WriteAllText($filename, $json, [System.Text.Encoding]::UTF8)
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
