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
Write-Host "C.P 비 및 조도 센서 v3.5.9" -ForegroundColor Cyan
Write-Host "제작자: 치즈가루" -ForegroundColor DarkGray
Write-Host "============================================================" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Packaging and installing the Edge driver..." -ForegroundColor Cyan
Write-Host "Select the requested channel or hub when prompted." -ForegroundColor Yellow
Write-Host ""

Invoke-ST -Arguments @("edge:drivers:package", ".", "--install")

Write-Host ""
Write-Host "설치 완료: v3.5.9" -ForegroundColor Green
Write-Host "기기 상세정보에 제작자와 버전이 표시됩니다." -ForegroundColor Green
Write-Host "기존 UI가 남아 있으면 SmartThings 앱을 완전히 종료한 뒤 다시 실행하세요." -ForegroundColor Yellow
