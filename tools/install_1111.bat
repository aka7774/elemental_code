@echo off
rem Windows用自動AUTOMATICインストーラー
rem 環境を汚さない(PythonとGitへのPATHも通さない)仕様にしたかったが...

rem インストールしたいディレクトリを作ってその中にこのファイルを入れて実行する
set INSTALL_DIR=%~dp0
cd /d %INSTALL_DIR%
mkdir dl

rem bitsadminはwget的なもの。標準搭載。便利だけどなんか遅い。
rem unzipコマンドは標準で存在しないらしい

rem 過去にPythonかGitをインストーラーで入れてる環境だとインストールに失敗する
bitsadmin /transfer python https://www.python.org/ftp/python/3.10.9/python-3.10.9-amd64.exe %INSTALL_DIR%dl\python-3.10.9-amd64.exe
%INSTALL_DIR%dl\python-3.10.9-amd64.exe /quiet TargetDir=%INSTALL_DIR%Python310 InstallAllUsers=1 Include_launcher=0

rem embed版はインストール版のようには使えない
rem bitsadmin /transfer python https://www.python.org/ftp/python/3.10.9/python-3.10.9-embed-amd64.zip %INSTALL_DIR%dl\python-3.10.9-embed-amd64.zip
rem call powershell -command "Expand-Archive -Force dl\python-3.10.9-embed-amd64.zip"
rem ren python-3.10.9-embed-amd64 python310

rem python用のpathを通す
rem echo import sys; sys.path.append('')>python310\current.pth
rem echo ./Lib/site-packages>>python310\python310._pth

rem pipインストール
rem set PYTHON=%INSTALL_DIR%python310\python.exe
rem set PATH=%PATH%;C:\SD2\python310\Scripts
rem bitsadmin /transfer pip https://bootstrap.pypa.io/get-pip.py %INSTALL_DIR%dl\get-pip.py
rem %PYTHON% %INSTALL_DIR%dl\get-pip.py

rem venvインストール
rem bitsadmin /transfer venv https://raw.githubusercontent.com/aka7774/elemental_code/main/tools/venv.zip %INSTALL_DIR%dl\venv.zip
rem call powershell -command "Expand-Archive -Force dl\venv.zip -DestinationPath python310\Lib\site-packages"

rem ensurepipインストール
rem bitsadmin /transfer ensurepip https://raw.githubusercontent.com/aka7774/elemental_code/main/tools/ensurepip.zip %INSTALL_DIR%dl\ensurepip.zip
rem call powershell -command "Expand-Archive -Force dl\ensurepip.zip -DestinationPath python310\Lib\site-packages"

rem gitインストール
bitsadmin /transfer git https://github.com/git-for-windows/git/releases/download/v2.39.0.windows.2/PortableGit-2.39.0.2-64-bit.7z.exe %INSTALL_DIR%PortableGit-2.39.0.2-64-bit.7z.exe
%INSTALL_DIR%PortableGit-2.39.0.2-64-bit.7z.exe -y
move PortableGit-2.39.0.2-64-bit.7z.exe dl\

set GIT=%INSTALL_DIR%PortableGit\bin\git
%GIT% clone https://github.com/AUTOMATIC1111/stable-diffusion-webui

rem 何もしないモデルをダウンロードする
bitsadmin /transfer model https://raw.githubusercontent.com/aka7774/elemental_code/main/tools/null.safetensors %INSTALL_DIR%stable-diffusion-webui\models\Stable-diffusion\null.safetensors

rem Filerを入れる(後で好きなモデルをダウンロードできるようにするため)
cd %INSTALL_DIR%stable-diffusion-webui\extensions
%GIT% clone https://github.com/aka7774/sd_filer.git

cd %INSTALL_DIR%

rem 起動用バッチ
echo @echo off>start.bat
echo set PATH=%%PATH%%;%INSTALL_DIR%python310\Scripts;%INSTALL_DIR%PortableGit\bin>>start.bat
echo set PYTHON=%INSTALL_DIR%python310\python.exe>>start.bat
echo set GIT=%GIT%.exe>>start.bat
echo set VENV_DIR=>>start.bat
echo set COMMANDLINE_ARGS=>>start.bat
echo cd /d %INSTALL_DIR%stable-diffusion-webui>>start.bat
echo call webui.bat>>start.bat

rem git pull用バッチ
echo cd /d %INSTALL_DIR%stable-diffusion-webui>pull.bat
echo %GIT% pull>>pull.bat
echo @pause>>pull.bat

call start.bat
