@echo off
rem Windows�p����AUTOMATIC�C���X�g�[���[
rem ���������Ȃ�(Python��Git�ւ�PATH���ʂ��Ȃ�)�d�l

rem �C���X�g�[���������f�B���N�g��������Ă��̒��ɂ��̃t�@�C�������Ď��s����
set INSTALL_DIR=%~dp0
cd /d %INSTALL_DIR%
mkdir dl

rem bitsadmin��wget�I�Ȃ��́B�W�����ځB�֗������ǂȂ񂩒x���B
bitsadmin /transfer python https://www.python.org/ftp/python/3.10.9/python-3.10.9-embed-amd64.zip %INSTALL_DIR%dl\python-3.10.9-embed-amd64.zip
rem unzip�R�}���h�͕W���ő��݂��Ȃ��炵��
call powershell -command "Expand-Archive -Force dl\python-3.10.9-embed-amd64.zip"
ren python-3.10.9-embed-amd64 python310

rem python�p��path��ʂ�
echo import sys; sys.path.append('')>python310\current.pth
echo ./Lib/site-packages>>python310\python310._pth

rem pip�C���X�g�[��
set PYTHON=%INSTALL_DIR%python310\python.exe
set PATH=%PATH%;C:\SD2\python310\Scripts
bitsadmin /transfer pip https://bootstrap.pypa.io/get-pip.py %INSTALL_DIR%dl\get-pip.py
%PYTHON% %INSTALL_DIR%dl\get-pip.py

rem venv�C���X�g�[��
bitsadmin /transfer venv https://raw.githubusercontent.com/aka7774/elemental_code/main/tools/venv.zip %INSTALL_DIR%dl\venv.zip
call powershell -command "Expand-Archive -Force dl\venv.zip -DestinationPath python310\Lib\site-packages"

rem ensurepip�C���X�g�[��
bitsadmin /transfer ensurepip https://raw.githubusercontent.com/aka7774/elemental_code/main/tools/ensurepip.zip %INSTALL_DIR%dl\ensurepip.zip
call powershell -command "Expand-Archive -Force dl\ensurepip.zip -DestinationPath python310\Lib\site-packages"

rem git�C���X�g�[��
bitsadmin /transfer git https://github.com/git-for-windows/git/releases/download/v2.39.0.windows.2/PortableGit-2.39.0.2-64-bit.7z.exe %INSTALL_DIR%PortableGit-2.39.0.2-64-bit.7z.exe
%INSTALL_DIR%PortableGit-2.39.0.2-64-bit.7z.exe -y
move PortableGit-2.39.0.2-64-bit.7z.exe dl\

set GIT=%INSTALL_DIR%PortableGit\bin\git
%GIT% clone https://github.com/AUTOMATIC1111/stable-diffusion-webui

rem �������Ȃ����f�����_�E�����[�h����
bitsadmin /transfer model https://raw.githubusercontent.com/aka7774/elemental_code/main/tools/null.safetensors %INSTALL_DIR%stable-diffusion-webui\models\Stable-diffusion\null.safetensors

rem Filer������(��ōD���ȃ��f�����_�E�����[�h�ł���悤�ɂ��邽��)
cd %INSTALL_DIR%stable-diffusion-webui\extensions
%GIT% clone https://github.com/aka7774/sd_filer.git

cd %INSTALL_DIR%

rem �N���p�o�b�`
echo @echo off>start.bat
echo set PATH=%%PATH%%;%INSTALL_DIR%python310\Scripts;%INSTALL_DIR%PortableGit\bin>>start.bat
echo set PYTHON=%INSTALL_DIR%python310\python.exe>>start.bat
echo set GIT=%GIT%.exe>>start.bat
echo set VENV_DIR=>>start.bat
echo set COMMANDLINE_ARGS=>>start.bat
echo cd /d %INSTALL_DIR%stable-diffusion-webui>>start.bat
echo call webui.bat>>start.bat

rem git pull�p�o�b�`
echo cd /d %INSTALL_DIR%stable-diffusion-webui>pull.bat
echo %GIT% pull>>pull.bat
echo @pause>>pull.bat

call start.bat
