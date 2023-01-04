@echo off
; Windows用自動AUTOMATICインストーラー
; PythonとGitへのPATHは通さない仕様

; インストールしたいディレクトリを作ってその中にこのファイルを入れて実行する
set INSTALL_DIR=%~dp0
cd /d %INSTALL_DIR%

; bitsadminはwget的なもの。標準搭載。便利だけどなんか遅い。
bitsadmin /transfer Python https://www.python.org/ftp/python/3.10.9/python-3.10.9-embed-amd64.zip %INSTALL_DIR%python-3.10.9-embed-amd64.zip
; unzipコマンドは標準で存在しないらしい
call powershell -command "Expand-Archive -Force python-3.10.9-embed-amd64.zip"
ren python-3.10.9-embed-amd64 python310

; pipインストール
set PYTHON=%INSTALL_DIR%python310\python.exe
set PATH=%PATH%;C:\SD2\python310\Scripts
bitsadmin /transfer pip https://bootstrap.pypa.io/get-pip.py %INSTALL_DIR%get-pip.py
%PYTHON% %INSTALL_DIR%get-pip.py

; venvインストール
%PYTHON% -m pip install venv

; インストーラー画面が開くのを抑制するのが困難。そのままEnterで入れる想定。
bitsadmin /transfer git https://github.com/git-for-windows/git/releases/download/v2.39.0.windows.2/PortableGit-2.39.0.2-64-bit.7z.exe %INSTALL_DIR%PortableGit-2.39.0.2-64-bit.7z.exe
%INSTALL_DIR%PortableGit-2.39.0.2-64-bit.7z.exe

set GIT=%INSTALL_DIR%PortableGit\bin\git
%GIT% clone https://github.com/AUTOMATIC1111/stable-diffusion-webui

; 何もしないモデルをダウンロードする
bitsadmin /transfer model https://raw.githubusercontent.com/aka7774/elemental_code/main/tools/null.safetensors %INSTALL_DIR%stable-diffusion-webui\models\Stable-diffusion\null.safetensors

; Filerを入れる(後で好きなモデルをダウンロードできるようにするため)
cd %INSTALL_DIR%stable-diffusion-webui\extensions
%GIT% clone https://github.com/aka7774/sd_filer.git

cd %INSTALL_DIR%

; 起動用バッチ
echo @echo off >> start.bat
echo set PATH=^%PATH^%;%INSTALL_DIR%\python310\Scripts;%INSTALL_DIR%PortableGit\bin >> start.bat
echo set PYTHON=%INSTALL_DIR%python310\python.exe >> start.bat
echo set GIT=%GIT%.exe >> start.bat
echo set VENV_DIR= >> start.bat
echo set COMMANDLINE_ARGS=--xformers >> start.bat
echo cd %INSTALL_DIR%stable-diffusion-webui >> start.bat
echo call webui.bat >> start.bat

; git pull用バッチ
echo cd %INSTALL_DIR%stable-diffusion-webui >> pull.bat
echo %GIT% pull >> pull.bat
echo @pause >> pull.bat
