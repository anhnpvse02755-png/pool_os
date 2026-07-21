param(
    [string]$OutputPath = ""
)

$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$packageRoot = Join-Path $repoRoot "packages\billiard_knowledge"
$appRoot = Join-Path $repoRoot "app"

$dirty = git -C $repoRoot status --porcelain
if ($dirty) {
    throw "M2.4 requires a clean checkout. Dirty paths: $($dirty -join ', ')"
}

if (-not $OutputPath) {
    $OutputPath = Join-Path $packageRoot "build\m2_4\proof.json"
}

Push-Location $packageRoot
try {
    flutter pub get
    dart run tool/knowledge_migration_v1_4.dart --check
    dart run tool/knowledge_reproducibility_proof.dart --output $OutputPath
    dart run tool/knowledge_publication.dart check --store publication
    flutter test
} finally {
    Pop-Location
}

Push-Location $appRoot
try {
    flutter pub get
    flutter test
} finally {
    Pop-Location
}

Push-Location $repoRoot
try {
    dart run tool/architecture_test.dart
    # Architecture Fitness intentionally refreshes its generated health
    # projection. Git can also report stat-only CRLF changes on generated
    # plugin registrants even when their content diff is empty. Gate on actual
    # content changes and allow only the health projection.
    $changedContent = @(git diff --name-only -- .) |
        Where-Object { $_ -and $_ -ne "build/architecture/health.json" }
    $stagedContent = @(git diff --cached --name-only -- .) |
        Where-Object { $_ }
    $untrackedContent = @(git ls-files --others --exclude-standard) |
        Where-Object { $_ }
    if ($changedContent -or $stagedContent -or $untrackedContent) {
        $unexpected = @($changedContent) + @($stagedContent) + @($untrackedContent)
        throw "M2.4 proof changed repository content: $($unexpected -join ', ')"
    }
} finally {
    Pop-Location
}

Write-Host "M2.4 full gate PASS. Proof: $OutputPath"
