$ErrorActionPreference = "Stop"
Set-Location -LiteralPath $PSScriptRoot

function Invoke-ST {
  param([Parameter(Mandatory = $true)][string[]]$Arguments)
  & smartthings @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw "SmartThings CLI command failed: smartthings $($Arguments -join ' ')"
  }
}

if (-not (Get-Command smartthings.exe -ErrorAction SilentlyContinue) -and
    -not (Get-Command smartthings -ErrorAction SilentlyContinue)) {
  throw "SmartThings CLI was not found. Install it or add it to PATH, then run this installer again."
}

Write-Host "============================================================" -ForegroundColor DarkGray
Write-Host "C.P Tuya Rain and Lux Sensor v3.5.4" -ForegroundColor Cyan
Write-Host "Author: CheesePowder" -ForegroundColor DarkGray
Write-Host "============================================================" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Packaging and installing the Edge driver..." -ForegroundColor Cyan
Write-Host "Select the requested channel or hub when prompted." -ForegroundColor Yellow
Write-Host ""

Invoke-ST -Arguments @("edge:drivers:package", ".", "--install")

Write-Host ""
Write-Host "Installation completed: v3.5.4" -ForegroundColor Green
Write-Host "Device details include Author and Version." -ForegroundColor Green
Write-Host "Force-close and reopen the SmartThings app if the old UI remains." -ForegroundColor Yellow
