@echo off
setlocal

set "HTTP_PROXY="
set "HTTPS_PROXY="
set "ALL_PROXY="
set "GIT_HTTP_PROXY="
set "GIT_HTTPS_PROXY="

start "" "C:\Users\graci\AppData\Local\Programs\Microsoft VS Code\Code.exe" --new-window --user-data-dir "C:\tmp\vscode-auth-test" --extensions-dir "C:\tmp\vscode-auth-test-extensions"
