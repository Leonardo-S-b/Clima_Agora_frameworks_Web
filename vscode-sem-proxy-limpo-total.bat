@echo off
setlocal

taskkill /F /IM Code.exe >nul 2>nul
timeout /t 2 /nobreak >nul

set "HTTP_PROXY="
set "HTTPS_PROXY="
set "ALL_PROXY="
set "GIT_HTTP_PROXY="
set "GIT_HTTPS_PROXY="

start "" "C:\Users\graci\AppData\Local\Programs\Microsoft VS Code\Code.exe" --new-window %*
