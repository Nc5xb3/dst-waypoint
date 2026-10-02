@echo off
rem Double-click wrapper for deploy-test.ps1 (bypasses the PowerShell execution policy for this run only).
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0deploy-test.ps1" %*
echo.
pause
