# PostToolUse hook: chạy `flutter analyze` khi một file .dart trong app/ vừa được sửa.
# Mục tiêu: ép Definition of Done (analyze = 0 errors) tự động, surface lỗi ngược lại cho Claude.
# Exit 0 = im lặng (pass hoặc không liên quan). Exit 2 = feed stderr về Claude để tự sửa.

$ErrorActionPreference = 'SilentlyContinue'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Đọc JSON hook input từ stdin
$raw = ""
try { if ([Console]::IsInputRedirected) { $raw = [Console]::In.ReadToEnd() } } catch { }
if ([string]::IsNullOrWhiteSpace($raw)) { exit 0 }

try { $data = ConvertFrom-Json $raw } catch { exit 0 }

$filePath = $null
if ($data.tool_input -and $data.tool_input.file_path) { $filePath = $data.tool_input.file_path }
if ([string]::IsNullOrWhiteSpace($filePath)) { exit 0 }

# Chỉ quan tâm file .dart nằm trong app/ của Pool OS
if ($filePath -notmatch '\.dart$') { exit 0 }
$norm = $filePath -replace '\\', '/'
if ($norm -notmatch '/Pool OS/app/') { exit 0 }
# Bỏ qua file generated của Drift/Riverpod (không sửa tay, analyze riêng dễ nhiễu)
if ($norm -match '\.(g|freezed)\.dart$') { exit 0 }

# Xác định thư mục app/ (chứa pubspec.yaml)
$appDir = ($norm -replace '(/Pool OS/app/).*$', '$1').TrimEnd('/')
if (-not (Test-Path $appDir)) { exit 0 }

# Tìm dart CLI (đi kèm Flutter). Ưu tiên PATH, fallback D:\flutter\bin
$dart = (Get-Command dart -ErrorAction SilentlyContinue).Source
if (-not $dart) { $dart = 'D:\flutter\bin\dart.bat' }
if (-not (Test-Path $dart)) { exit 0 }

Push-Location $appDir
try {
    # analyze phạm vi file vừa sửa cho nhanh; đủ để bắt lỗi cú pháp/type ngay
    $out = & $dart analyze "$filePath" 2>&1 | Out-String
} finally { Pop-Location }

if ($out -match 'No issues found') { exit 0 }
if ($out -match '(\d+)\s+issue') {
    Write-Error "flutter/dart analyze phát hiện vấn đề ở file vừa sửa:`n$out`nTuân DoD Pool OS: phải sửa cho analyze = 0 errors trước khi đóng FIX."
    exit 2
}
exit 0
