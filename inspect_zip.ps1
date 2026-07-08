Add-Type -AssemblyName System.IO.Compression.FileSystem
$path = 'C:\Android\Sdk\cmdline-tools.zip'
if (Test-Path $path) {
  $zip = [System.IO.Compression.ZipFile]::OpenRead($path)
  Write-Host ('Entries: ' + $zip.Entries.Count)
  $zip.Entries | Select-Object -First 20 | ForEach-Object { Write-Host $_.FullName }
  $zip.Dispose()
} else {
  Write-Host 'Zip not found'
}
