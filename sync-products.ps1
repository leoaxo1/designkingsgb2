$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$madeCustomsFolder = Join-Path $root "made customs"
$previousWorkFolder = Join-Path $root "previous work"
$outputFile = Join-Path $root "assets\products.js"
$price = "GBP 10"

foreach ($folder in @($madeCustomsFolder, $previousWorkFolder)) {
  if (-not (Test-Path $folder)) {
    New-Item -ItemType Directory -Path $folder | Out-Null
  }
}

function Convert-ToProductName {
  param([string]$BaseName)

  $spaced = $BaseName -replace '[_-]+', ' '
  return (Get-Culture).TextInfo.ToTitleCase($spaced.ToLower())
}

function Get-GalleryItems {
  param(
    [string]$FolderPath,
    [string]$RelativeFolder,
    [string]$Description,
    [string]$Status,
    [string]$Label,
    [bool]$IncludePrice
  )

  return Get-ChildItem -Path $FolderPath -File -Filter *.png |
    Sort-Object Name |
    ForEach-Object {
      $encodedName = [System.Uri]::EscapeDataString($_.Name)
      [pscustomobject]@{
        name = Convert-ToProductName $_.BaseName
        image = "$RelativeFolder/$encodedName"
        description = $Description
        price = if ($IncludePrice) { $price } else { $null }
        label = $Label
        status = $Status
      }
    }
}

$madeCustoms = Get-GalleryItems -FolderPath $madeCustomsFolder -RelativeFolder "made customs" -Description "Custom PNG upload synced from your made customs folder." -Status "Ready to order" -Label "GBP 10" -IncludePrice $true
$previousWork = Get-GalleryItems -FolderPath $previousWorkFolder -RelativeFolder "previous work" -Description "Completed project synced from your previous work folder." -Status "Portfolio piece" -Label "Completed" -IncludePrice $false

$madeCustomsJson = $madeCustoms | ConvertTo-Json -Depth 3
if (-not $madeCustomsJson) {
  $madeCustomsJson = "[]"
}

$previousWorkJson = $previousWork | ConvertTo-Json -Depth 3
if (-not $previousWorkJson) {
  $previousWorkJson = "[]"
}

$content = @"
window.MADE_CUSTOMS_PRODUCTS = $madeCustomsJson;
window.PREVIOUS_WORK_ITEMS = $previousWorkJson;
"@

Set-Content -Path $outputFile -Value $content -Encoding UTF8
Write-Host "Synced $($madeCustoms.Count) made custom item(s) and $($previousWork.Count) previous work item(s) to $outputFile"
