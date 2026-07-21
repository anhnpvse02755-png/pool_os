param(
    [string]$OutputPath = ""
)

$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$packageRoot = Join-Path $repoRoot "packages\billiard_knowledge"
$appRoot = Join-Path $repoRoot "app"

$dirty = git -C $repoRoot status --porcelain
if ($dirty) {
    throw "M2 Final Validation requires a clean checkout: $($dirty -join ', ')"
}

if (-not $OutputPath) {
    $OutputPath = Join-Path $packageRoot "build\m2_final\m2_4_proof.json"
}

Push-Location $packageRoot
try {
    flutter pub get
    dart run tool/knowledge_compiler_v0.dart --check
    dart run tool/knowledge_migration_v1_4.dart --check
    dart run tool/knowledge_reproducibility_proof.dart --output $OutputPath
    dart run tool/knowledge_publication.dart check --store publication
    dart run tool/learning_dependency_fixture.dart --check
    dart run tool/learning_unlock_fixture.dart --check
    dart run tool/canonical_package_fixture.dart --check
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
    $changedContent = @(git diff --name-only -- .) |
        Where-Object { $_ -and $_ -ne "build/architecture/health.json" }
    $stagedContent = @(git diff --cached --name-only -- .) | Where-Object { $_ }
    $untrackedContent = @(git ls-files --others --exclude-standard) | Where-Object { $_ }
    if ($changedContent -or $stagedContent -or $untrackedContent) {
        $unexpected = @($changedContent) + @($stagedContent) + @($untrackedContent)
        throw "M2 Final Validation changed repository content: $($unexpected -join ', ')"
    }
} finally {
    Pop-Location
}

Write-Host "M2 Final Validation PASS. M2.4 proof: $OutputPath"
