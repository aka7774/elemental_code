@echo off

if exist start.bat goto install

echo start.bat no aru folder ni oitene ;-;
pause>null
exit

:install
set PATH=%PATH%;%cd%\PortableGit\bin
SET PYTHON=%cd%\Python310\Python.exe
SET GIT=%cd%\PortableGit\bin\git.exe
set VENV_DIR=venv

cd C:\SD
%GIT% clone https://github.com/invoke-ai/InvokeAI.git
cd InvokeAI

copy environments-and-requirements\requirements-win-colab-cuda.txt requirements.txt

%PYTHON% -m venv %VENV_DIR%
%VENV_DIR%\Scripts\python.exe -m pip install --prefer-binary -r requirements.txt

echo Done!
pause
