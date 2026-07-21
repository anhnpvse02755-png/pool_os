param(
    [string]$FirstProofPath = "",
    [string]$SecondProofPath = ""
)

$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$appRoot = Join-Path $repoRoot "app"
$knowledgeRoot = Join-Path $repoRoot "packages\billiard_knowledge"

$dirty = git -C $repoRoot status --porcelain
if ($dirty) {
    throw "M3 Foundation Freeze requires a clean checkout: $($dirty -join ', ')"
}

if (-not $FirstProofPath) {
    $FirstProofPath = Join-Path $repoRoot "build\m3_freeze\proof_first.json"
}
if (-not $SecondProofPath) {
    $SecondProofPath = Join-Path $repoRoot "build\m3_freeze\proof_second.json"
}

Push-Location $appRoot
try {
    flutter pub get
    dart run tool/m3_foundation_freeze.dart --root .. --output $FirstProofPath
    dart run tool/m3_foundation_freeze.dart --root .. --output $SecondProofPath
    if ((Get-FileHash $FirstProofPath -Algorithm SHA256).Hash -ne
        (Get-FileHash $SecondProofPath -Algorithm SHA256).Hash) {
        throw "M3 Foundation Freeze proof is not deterministic."
    }
    flutter test test/player_model_foundation_test.dart `
        test/experience_projection_foundation_test.dart `
        test/coach_context_foundation_test.dart `
        test/coach_decision_engine_foundation_test.dart `
        test/coach_decision_lifecycle_foundation_test.dart `
        test/coach_planning_foundation_test.dart `
        test/coach_recommendation_foundation_test.dart `
        test/coach_execution_foundation_test.dart `
        test/ai_session_boundary_foundation_test.dart `
        test/coach_response_foundation_test.dart `
        test/ai_capability_registry_foundation_test.dart `
        test/ai_provider_foundation_test.dart `
        test/ai_orchestration_foundation_test.dart `
        test/m3_foundation_freeze_test.dart
    flutter test
} finally {
    Pop-Location
}

Push-Location $knowledgeRoot
try {
    flutter pub get
    flutter test
} finally {
    Pop-Location
}

Push-Location $repoRoot
try {
    dart run tool/architecture_test.dart
    $unexpected = @(git diff --ignore-space-at-eol --name-only -- .) |
        Where-Object {
            $_ -and
            $_ -ne "build/architecture/health.json" -and
            $_ -notmatch '^app/(linux|macos|windows)/(flutter|Flutter)/(generated_|GeneratedPluginRegistrant\.)'
        }
    if ($unexpected) {
        throw "M3 Foundation Freeze changed tracked content: $($unexpected -join ', ')"
    }
    $untracked = @(git ls-files --others --exclude-standard) |
        Where-Object { $_ -and -not $_.StartsWith("build/") }
    if ($untracked) {
        throw "M3 Foundation Freeze created unexpected files: $($untracked -join ', ')"
    }
} finally {
    Pop-Location
}

Write-Host "M3 Foundation Freeze clean-checkout gate PASS."
