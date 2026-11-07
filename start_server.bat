@echo off
setlocal
cd /d "%~dp0"
set "PATH=C:\Users\arsen\.local\bin;%PATH%"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0start_server.ps1"
pause
