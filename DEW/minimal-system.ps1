#!/usr/bin/env pwsh
# minimal-system.ps1 - A minimal interactive system built with PowerShell.
# Commands: help, info, read <path>, echo <text>, pwsh <command>, exit

param(
  [string]$Command,
  [string]$Argument
)

function Show-Help {
  Write-Host 'Minimal System'
  Write-Host 'Commands:'
  Write-Host '  help            Show this help'
  Write-Host '  info            Show minimal system information'
  Write-Host '  read <path>     Read a UTF-8 text file'
  Write-Host '  echo <text>     Print text'
  Write-Host '  pwsh <command>  Run a PowerShell command'
  Write-Host '  exit            Exit the REPL'
}

function Invoke-PwshCommand([string]$CommandText) {
  if ([string]::IsNullOrWhiteSpace($CommandText)) {
    Write-Error 'Usage: pwsh <command>'
    return
  }
  try {
    Invoke-Expression $CommandText
  } catch {
    Write-Error $_
  }
}

function Show-Info {
  $os = [System.Environment]::OSVersion.VersionString
  $ps = $PSVersionTable.PSVersion.ToString()
  $cpu = $env:PROCESSOR_ARCHITECTURE
  Write-Host "OS: $os"
  Write-Host "PowerShell: $ps"
  Write-Host "Architecture: $cpu"
}

function Read-FileContent([string]$Path) {
  if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
    Write-Error "File not found: $Path"
    return
  }
  Get-Content -LiteralPath $Path -Raw -Encoding UTF8
}

if ($Command) {
  switch ($Command.ToLower()) {
    'help' { Show-Help }
    'info' { Show-Info }
    'read' { Read-FileContent $Argument }
    'echo' { Write-Output $Argument }
    'pwsh' { Invoke-PwshCommand $Argument }
    default { Write-Error "Unknown command: $Command"; Show-Help; exit 1 }
  }
  exit 0
}

Show-Help
while ($true) {
  $input = Read-Host '> '
  if ($input -eq 'exit') { break }
  $parts = $input -split ' ', 2
  $cmd = $parts[0]
  $arg = if ($parts.Count -gt 1) { $parts[1] } else { '' }
  switch ($cmd.ToLower()) {
    'help' { Show-Help }
    'info' { Show-Info }
    'read' { Read-FileContent $arg }
    'echo' { Write-Output $arg }
    'pwsh' { Invoke-PwshCommand $arg }
    default { Write-Host "Unknown command: $cmd" }
  }
}
