$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

function Run-ST {
  param([string[]]$Arguments)
  & smartthings @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw "SmartThings CLI command failed: smartthings $($Arguments -join ' ')"
  }
}

Write-Host "[1/4] Checking SmartThings custom capability..." -ForegroundColor Cyan
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

Write-Host "[2/4] Creating or updating capability presentation..." -ForegroundColor Cyan
# Version 1 is the CLI default. Some SmartThings CLI builds incorrectly reject
# an explicit positional version and crash in unknownArguments, so omit it.
& smartthings capabilities:presentation:create $capabilityId -i "custom-capability\driver-info-presentation.json"
if ($LASTEXITCODE -ne 0) {
  Write-Host "Create failed; trying presentation update..." -ForegroundColor Yellow
  Run-ST @("capabilities:presentation:update", $capabilityId, "-i", "custom-capability\driver-info-presentation.json")
}

Write-Host "[3/4] Applying capability ID to driver files..." -ForegroundColor Cyan
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$profileTemplate = Get-Content "templates\rain-lux-sensor.yml.template" -Raw -Encoding UTF8
[System.IO.File]::WriteAllText((Join-Path $PSScriptRoot "profiles\rain-lux-sensor.yml"), $profileTemplate.Replace("__CAPABILITY_ID__", $capabilityId), $utf8NoBom)

$luaTemplate = Get-Content "templates\init.lua.template" -Raw -Encoding UTF8
[System.IO.File]::WriteAllText((Join-Path $PSScriptRoot "src\init.lua"), $luaTemplate.Replace("__CAPABILITY_ID__", $capabilityId), $utf8NoBom)

Write-Host "[4/4] Packaging and installing driver to hub..." -ForegroundColor Cyan
Run-ST @("edge:drivers:package", ".", "--install")

Write-Host ""
Write-Host "Done. Added author and driver version fields." -ForegroundColor Green
Write-Host "Force-close and reopen the SmartThings app."
