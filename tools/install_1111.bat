; Windows用自動AUTOMATICインストーラー(動作未確認)
; PythonとGitへのPATHは通さない仕様
; 過去にPythonかGitをインストーラーで入れてる環境だとインストールに失敗する
; 一度手動アンインストールしてからなら動くかも知れない

; インストールしたいディレクトリを作ってその中にこのファイルを入れて実行する
; たぶんCドライブ以外だともう一工夫しないと動かない
set INSTALL_DIR=%~dp0

; bitsadminはwget的なもの。標準搭載。便利だけどなんか遅い。
bitsadmin /transfer a https://www.python.org/ftp/python/3.10.9/python-3.10.9-amd64.exe %INSTALL_DIR%python-3.10.9-amd64.exe
%INSTALL_DIR%python-3.10.9-amd64.exe /quiet TargetDir=%INSTALL_DIR%Python310 InstallAllUsers=1 Include_launcher=0

; インストーラー画面が開くのを抑制するのが困難。そのままEnterで入れる想定。
bitsadmin /transfer b https://github.com/git-for-windows/git/releases/download/v2.38.1.windows.1/PortableGit-2.38.1-64-bit.7z.exe %INSTALL_DIR%PortableGit-2.38.1-64-bit.7z.exe
%INSTALL_DIR%PortableGit-2.38.1-64-bit.7z.exe

set GIT=%INSTALL_DIR%PortableGit\bin\git
%GIT% clone https://github.com/AUTOMATIC1111/stable-diffusion-webui

; Anythingは認証無しでダウンロードできる
bitsadmin /transfer c https://huggingface.co/acheong08/Anything/resolve/main/Anything-V3.0-pruned-fp16.ckpt %INSTALL_DIR%stable-diffusion-webui\models\Stable-diffusion\Anything-V3.0-pruned-fp16.ckpt
; とりあえずファイル名を変えてそのまま読み込めるようにする
bitsadmin /transfer d https://huggingface.co/acheong08/Anything/resolve/main/Anything-V3.0.vae.pt %INSTALL_DIR%stable-diffusion-webui\models\Stable-diffusion\Anything-V3.0-pruned-fp16.vae.pt

; 好きなEntensionを入れる(まるで日本製のPCのように)
cd %INSTALL_DIR%stable-diffusion-webui\extensions
;%GIT% clone https://github.com/d8ahazard/sd_dreambooth_extension.git
%GIT% clone https://github.com/animerl/novelai-2-local-prompt.git
%GIT% clone https://github.com/yfszzx/stable-diffusion-webui-images-browser.git
%GIT% clone https://github.com/aka7774/sd_katanuki.git
%GIT% clone https://github.com/aka7774/sd_filer.git
%GIT% clone https://github.com/kousw/stable-diffusion-webui-daam.git

cd %INSTALL_DIR%

; 起動用バッチ
echo @echo off >> start.bat
echo set PATH=^%PATH^%;%INSTALL_DIR%PortableGit\bin >> start.bat
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
