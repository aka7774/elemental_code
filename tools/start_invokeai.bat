@echo off

set PATH=%PATH%;%cd%\PortableGit\bin
SET PYTHON=%cd%\Python310\Python.exe
SET GIT=%cd%\PortableGit\bin\git.exe
set VENV_DIR=venv

cd InvokeAI
%VENV_DIR%\Scripts\python.exe scripts/invoke.py --web
pause
