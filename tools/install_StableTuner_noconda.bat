@echo off

rem set PATH=%PATH%;C:\SD\PortableGit\bin
rem set PYTHON=C:\SD\python310\python.exe
rem set GIT=C:\SD\PortableGit\bin\git.exe

set PYTHON=python.exe
set GIT=git.exe



set VENV_DIR=venv
set INSTALL_DIR=%~dp0
cd /d %INSTALL_DIR%
mkdir dl

%GIT% clone https://github.com/devilismyfriend/StableTuner
cd StableTuner

%PYTHON% -m venv %VENV_DIR%

set PYTHON=%INSTALL_DIR%StableTuner\%VENV_DIR%\Scripts\Python.exe
set PATH=%PATH%;%INSTALL_DIR%StableTuner\%VENV_DIR%\Scripts

echo @echo off>%INSTALL_DIR%start.bat
echo cd /d %INSTALL_DIR%StableTuner>>%INSTALL_DIR%start.bat
echo %PYTHON% scripts/configuration_gui.py>>%INSTALL_DIR%start.bat

%PYTHON% -m pip install requests

%PYTHON% scripts/windows_install.py
%PYTHON% scripts/configuration_gui.py
pause
