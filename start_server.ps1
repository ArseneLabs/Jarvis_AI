<#
.SYNOPSIS
    Starts OpenJarvis Server accessible from PC and iPhone 13 Pro.
#>

$ErrorActionPreference = 'Stop'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Ensure uv is on PATH
$uvDir = "C:\Users\arsen\.local\bin"
if (Test-Path $uvDir) {
    $env:Path = "$uvDir;$env:Path"
}

# Load .env file if present in the project directory
$envFile = Join-Path $ScriptDir ".env"
if (Test-Path $envFile) {
    Write-Host "[info] Loading environment variables from .env..." -ForegroundColor Cyan
    Get-Content $envFile | Where-Object { $_ -match '^\s*([^#][^=]+)=(.*)$' } | ForEach-Object {
        $name = $matches[1].Trim()
        $value = $matches[2].Trim()
        [System.Environment]::SetEnvironmentVariable($name, $value, [System.EnvironmentVariableTarget]::Process)
        Set-Item "env:$name" $value
    }
}

# Detect active Wi-Fi / Local IPv4
$localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { 
    $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.254*" 
} | Select-Object -First 1).IPAddress

# Server auth key (from .env or generated)
$authKey = if ($env:OPENJARVIS_API_KEY) { 
    $env:OPENJARVIS_API_KEY 
} else { 
    "jarvis_local_access" 
}
$env:OPENJARVIS_API_KEY = $authKey

Write-Host "==========================================================" -ForegroundColor Green
Write-Host "                  JARVIS SERVER LAUNCHER                  " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "PC Local URL:    http://127.0.0.1:8000" -ForegroundColor Cyan
Write-Host "iPhone 13 Pro:   http://${localIP}:8000" -ForegroundColor Yellow
Write-Host "Server Auth Key: $authKey" -ForegroundColor Magenta
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "Tip: On iPhone Safari, tap Share -> 'Add to Home Screen' to" -ForegroundColor Gray
Write-Host "     use Jarvis like a native standalone app!" -ForegroundColor Gray
Write-Host ""

Set-Location $ScriptDir
& uv run jarvis serve --host 0.0.0.0 --port 8000
