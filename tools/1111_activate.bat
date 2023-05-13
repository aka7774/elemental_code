@echo off
cd /d %~dp0
set USERPROFILE=%CD%
set PATH=%CD%\stable-diffusion-webui\venv\Scripts;%CD%\PortableGit;%CD%\PortableGit\bin;%CD%\PortableGit\mingw64\bin
cd stable-diffusion-webui\venv\Scripts

echo %0:
echo.
:loop
  set /p user_input=
  %user_input%
  goto :loop
