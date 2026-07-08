Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead('C:\Android\Sdk\cmdline-tools.zip')
$zip.Entries | Select-Object -First 20 FullName
$zip.Dispose()
