@echo off

rem -------------------------------------------
rem NOT guaranteed to work on Windows

set APPDIR=stable-diffusion-webui-forge
set REPOS=https://github.com/lllyasviel/stable-diffusion-webui-forge

rem -------------------------------------------

set INSTALL_DIR=%~dp0
cd /d %INSTALL_DIR%

:git_clone
set GIT=git
set DL_URL=%REPOS%
set DL_DST=%APPDIR%
%GIT% clone %DL_URL% %APPDIR%
if exist %DL_DST% goto install_python

set DL_URL=https://github.com/git-for-windows/git/releases/download/v2.41.0.windows.3/PortableGit-2.41.0.3-64-bit.7z.exe
set DL_DST=PortableGit-2.41.0.3-64-bit.7z.exe
curl -L -o %DL_DST% %DL_URL%
if not exist %DL_DST% bitsadmin /transfer dl %DL_URL% %DL_DST%
%DL_DST% -y
del %DL_DST%

set GIT=%INSTALL_DIR%PortableGit\bin\git.exe
%GIT% clone %REPOS%

:install_python
set DL_URL=https://github.com/indygreg/python-build-standalone/releases/download/20240415/cpython-3.10.14+20240415-x86_64-pc-windows-msvc-shared-install_only.tar.gz
set DL_DST="%INSTALL_DIR%python.tar.gz"
curl -L -o %DL_DST% %DL_URL%
if not exist %DL_DST% bitsadmin /transfer dl %DL_URL% %DL_DST%
tar -xzf %DL_DST%
del %DL_DST%

set PYTHON=%INSTALL_DIR%python\python.exe
set PATH=%PATH%;%INSTALL_DIR%python\Scripts

:install_forge
cd %APPDIR%\models\Stable-diffusion
curl -L -o animagine-xl-3.1.safetensors https://huggingface.co/cagliostrolab/animagine-xl-3.1/resolve/main/animagine-xl-3.1.safetensors
curl -L -o flux1-dev-bnb-nf4-v2.safetensors https://huggingface.co/lllyasviel/flux1-dev-bnb-nf4/resolve/main/flux1-dev-bnb-nf4-v2.safetensors
cd ..\..

cd ..
echo @echo off>start.bat
echo set PATH=%%PATH%%;%INSTALL_DIR%python\Scripts>>start.bat
echo set PYTHON=%INSTALL_DIR%python\python.exe>>start.bat
echo set GIT=%GIT%>>start.bat
echo set VENV_DIR=>>start.bat
echo set COMMANDLINE_ARGS=--api --autolaunch>>start.bat
echo cd /d %INSTALL_DIR%%APPDIR%>>start.bat
echo call webui.bat>>start.bat

echo cd /d %INSTALL_DIR%%APPDIR%>pull.bat
echo %GIT% pull>>pull.bat
echo @pause>>pull.bat

call start.bat

pause
