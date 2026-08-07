$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

function Run-ST {
  param([string[]]$Arguments)
  & smartthings @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw "SmartThings CLI command failed: smartthings $($Arguments -join ' ')"
  }
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

Write-Host "[1/5] Checking SmartThings custom capability..." -ForegroundColor Cyan
$listFile = Join-Path $PSScriptRoot "custom-capability\capabilities-list.json"
if (Test-Path $listFile) { Remove-Item $listFile -Force }

$capabilityId = $null
Run-ST @("capabilities", "-o", $listFile)
$caps = Get-Content $listFile -Raw -Encoding UTF8 | ConvertFrom-Json

$existing = @($caps) | Where-Object {
  $_.id -match '\.(driverInformation|driverInfo)$' -or
  ($_.name -eq 'Driver Information')
} | Select-Object -First 1

if ($existing) {
  $capabilityId = $existing.id
  Write-Host "Using existing capability: $capabilityId" -ForegroundColor Green
}

if (-not $capabilityId) {
  Write-Host "Creating Driver Information capability..." -ForegroundColor Yellow
  $createdFile = Join-Path $PSScriptRoot "custom-capability\created-capability.json"
  if (Test-Path $createdFile) { Remove-Item $createdFile -Force }
  Run-ST @("capabilities:create", "-i", "custom-capability\driver-info-capability.json", "-o", $createdFile)
  $created = Get-Content $createdFile -Raw -Encoding UTF8 | ConvertFrom-Json
  $capabilityId = $created.id
}

if (-not $capabilityId) {
  throw "Unable to determine the custom capability ID."
}
Write-Host "Capability ID: $capabilityId" -ForegroundColor Green

Write-Host "[2/5] Creating or updating capability presentation..." -ForegroundColor Cyan
& smartthings capabilities:presentation:create $capabilityId -i "custom-capability\driver-info-presentation.json"
if ($LASTEXITCODE -ne 0) {
  Write-Host "Create failed; trying presentation update..." -ForegroundColor Yellow
  Run-ST @("capabilities:presentation:update", $capabilityId, "-i", "custom-capability\driver-info-presentation.json")
}

Write-Host "[3/5] Creating Water + Lux dashboard presentation..." -ForegroundColor Cyan
$deviceConfigTemplate = Get-Content "templates\device-config.json.template" -Raw -Encoding UTF8
$deviceConfigFile = Join-Path $PSScriptRoot "device-config.generated.json"
[System.IO.File]::WriteAllText($deviceConfigFile, $deviceConfigTemplate.Replace("__CAPABILITY_ID__", $capabilityId), $utf8NoBom)

$presentationFile = Join-Path $PSScriptRoot "device-presentation.generated.json"
if (Test-Path $presentationFile) { Remove-Item $presentationFile -Force }
Run-ST @("presentation:device-config:create", "-i", $deviceConfigFile, "-j", "-o", $presentationFile)
$presentation = Get-Content $presentationFile -Raw -Encoding UTF8 | ConvertFrom-Json

$presentationId = $presentation.vid
if (-not $presentationId) { $presentationId = $presentation.presentationId }
$manufacturerName = $presentation.mnmn
if (-not $manufacturerName) { $manufacturerName = $presentation.manufacturerName }
if (-not $manufacturerName) { $manufacturerName = "SmartThingsCommunity" }

if (-not $presentationId) {
  throw "Unable to determine the device presentation VID."
}
Write-Host "Presentation VID: $presentationId" -ForegroundColor Green

Write-Host "[4/5] Applying capability and presentation IDs..." -ForegroundColor Cyan
$profileTemplate = Get-Content "templates\rain-lux-sensor.yml.template" -Raw -Encoding UTF8
$profileText = $profileTemplate.Replace("__CAPABILITY_ID__", $capabilityId).Replace("__PRESENTATION_ID__", $presentationId).Replace("__MANUFACTURER_NAME__", $manufacturerName)
[System.IO.File]::WriteAllText((Join-Path $PSScriptRoot "profiles\rain-lux-sensor.yml"), $profileText, $utf8NoBom)

$luaTemplate = Get-Content "templates\init.lua.template" -Raw -Encoding UTF8
[System.IO.File]::WriteAllText((Join-Path $PSScriptRoot "src\init.lua"), $luaTemplate.Replace("__CAPABILITY_ID__", $capabilityId), $utf8NoBom)

Write-Host "[5/5] Packaging and installing driver to hub..." -ForegroundColor Cyan
Run-ST @("edge:drivers:package", ".", "--install")

Write-Host ""
Write-Host "Done. Dashboard summary is configured for Water + Lux only." -ForegroundColor Green
Write-Host "Battery remains available in device details but is excluded from the dashboard summary." -ForegroundColor Green
Write-Host "If an already-paired device keeps the old UI, remove and pair it again after installing this build." -ForegroundColor Yellow
Write-Host "Force-close and reopen the SmartThings app." -ForegroundColor Yellow
