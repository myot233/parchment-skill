@echo off
setlocal
"%~dp0x86_64-pc-windows-msvc\parchment.exe" %*
exit /b %errorlevel%
