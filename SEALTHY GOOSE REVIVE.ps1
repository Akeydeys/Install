$extractedFolder = [System.IO.Path]::Combine($env:TEMP, "Desktop-Goose-v0.31")

$gooseDesktopPath = Get-ChildItem -Path $extractedFolder -Recurse -Filter "GooseDesktop.exe" | Select-Object -First 1

Start-Process -FilePath $gooseDesktopPath.FullName

Remove-Item (Get-PSreadlineOption).HistorySavePath -Force