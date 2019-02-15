# startup.ps1


$downloadUrl = "https://cloud.r-project.org/bin/windows/base/R-3.5.2-win.exe"

$executable = Split-Path $downloadUrl -Leaf
$downloadLoc = Join-Path -Path $home -ChildPath "Desktop"
$newPath = Join-Path $downloadLoc -ChildPath $executable
Start-BitsTransfer -Source $downloadUrl -Destination $newPath
Start-Process $newPath