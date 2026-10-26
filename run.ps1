$ErrorActionPreference = "Stop"

$mavenVersion = "3.9.6"
$mavenDir = "$PSScriptRoot\apache-maven-$mavenVersion"
$env:Path = "$mavenDir\bin;" + $env:Path

if (Test-Path "C:\Program Files\Java\jdk-17") {
    $env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
    $env:Path = "$env:JAVA_HOME\bin;" + $env:Path
}

Write-Host "Killing any existing Tomcat processes on port 8081..."
$pids = netstat -ano | Select-String ":8081" | ForEach-Object { ($_ -split '\s+')[-1] } | Sort-Object -Unique
foreach ($p in $pids) {
    if ($p -match '^\d+$') {
        try { Stop-Process -Id $p -Force -ErrorAction SilentlyContinue; Write-Host "Killed PID $p" } catch {}
    }
}
Start-Sleep -Seconds 2

Write-Host "Building project (package)..."
mvn clean package -DskipTests
if ($LASTEXITCODE -ne 0) { Write-Error "Build failed!"; exit 1 }

Write-Host "Starting Tomcat 10 on port 8081..."
mvn cargo:run
