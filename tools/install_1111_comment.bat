@echo off
rem Windows用全自動AUTOMATICインストーラー
rem 環境を汚さない(PythonとGitへのPATHも通さない)仕様

rem インストールしたいディレクトリを作ってその中にこのファイルを入れて実行する
set INSTALL_DIR=%~dp0
cd /d %INSTALL_DIR%
mkdir dl

rem bitsadminはwget的なもの。標準搭載。便利だけどなんか遅い。
rem unzipコマンドは標準で存在しないらしい

rem nuget版pythonのダウンロード
bitsadmin /transfer nuget https://aka.ms/nugetclidl %INSTALL_DIR%dl\nuget.exe
%INSTALL_DIR%dl\nuget.exe install python -Version 3.10.9 -ExcludeVersion -OutputDirectory .
move python\tools python310
rmdir /s /q python

rem pipインストール
set PYTHON=%INSTALL_DIR%python310\python.exe
set PATH=%PATH%;%INSTALL_DIR%python310\Scripts
bitsadmin /transfer pip https://bootstrap.pypa.io/get-pip.py %INSTALL_DIR%dl\get-pip.py
%PYTHON% %INSTALL_DIR%dl\get-pip.py

rem gitインストール
bitsadmin /transfer git https://github.com/git-for-windows/git/releases/download/v2.39.0.windows.2/PortableGit-2.39.0.2-64-bit.7z.exe %INSTALL_DIR%PortableGit-2.39.0.2-64-bit.7z.exe
%INSTALL_DIR%PortableGit-2.39.0.2-64-bit.7z.exe -y
move PortableGit-2.39.0.2-64-bit.7z.exe dl\

set GIT=%INSTALL_DIR%PortableGit\bin\git
%GIT% clone https://github.com/AUTOMATIC1111/stable-diffusion-webui

rem 何もしないモデルをダウンロードする
bitsadmin /transfer model https://raw.githubusercontent.com/aka7774/elemental_code/main/tools/null.safetensors %INSTALL_DIR%stable-diffusion-webui\models\Stable-diffusion\null.safetensors

rem Filerを入れる(後で好きなモデルをダウンロードできるようにするため)
cd /d %INSTALL_DIR%stable-diffusion-webui\extensions
%GIT% clone https://github.com/aka7774/sd_filer.git

cd /d %INSTALL_DIR%

rem 起動用バッチ
echo @echo off>start.bat
echo set PATH=%%PATH%%;%INSTALL_DIR%python310\Scripts;%INSTALL_DIR%PortableGit\bin>>start.bat
echo set PYTHON=%INSTALL_DIR%python310\python.exe>>start.bat
echo set GIT=%GIT%.exe>>start.bat
echo set VENV_DIR=>>start.bat
echo set COMMANDLINE_ARGS=--autolaunch>>start.bat
echo cd /d %INSTALL_DIR%stable-diffusion-webui>>start.bat
echo call webui.bat>>start.bat

rem git pull用バッチ
echo cd /d %INSTALL_DIR%stable-diffusion-webui>pull.bat
echo %GIT% pull>>pull.bat
echo @pause>>pull.bat

call start.bat

rem うまくいかなかった時に窓がすぐ消えないようにする
echo ERROR! ｡ﾟ･（＞＿＜）･ﾟ｡
@pause >nul
