$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourceFolders = @(
  (Join-Path $root "made customs"),
  (Join-Path $root "previous work")
)
$syncScript = Join-Path $root "sync-products.ps1"

foreach ($folder in $sourceFolders) {
  if (-not (Test-Path $folder)) {
    New-Item -ItemType Directory -Path $folder | Out-Null
  }
}

& $syncScript

$watchers = @()
$events = @()

$action = {
  Start-Sleep -Milliseconds 250
  & $using:syncScript
}

foreach ($folder in $sourceFolders) {
  $watcher = New-Object System.IO.FileSystemWatcher
  $watcher.Path = $folder
  $watcher.Filter = "*.png"
  $watcher.IncludeSubdirectories = $false
  $watcher.NotifyFilter = [System.IO.NotifyFilters]'FileName, LastWrite, CreationTime'
  $watcher.EnableRaisingEvents = $true
  $watchers += $watcher

  $events += Register-ObjectEvent -InputObject $watcher -EventName Created -Action $action
  $events += Register-ObjectEvent -InputObject $watcher -EventName Changed -Action $action
  $events += Register-ObjectEvent -InputObject $watcher -EventName Deleted -Action $action
  $events += Register-ObjectEvent -InputObject $watcher -EventName Renamed -Action $action
}

Write-Host "Watching made customs and previous work for PNG changes. Press Ctrl+C to stop."

try {
  while ($true) {
    Wait-Event -Timeout 5 | Out-Null
  }
}
finally {
  foreach ($event in $events) {
    Unregister-Event -SourceIdentifier $event.Name
  }
  foreach ($watcher in $watchers) {
    $watcher.Dispose()
  }
}
