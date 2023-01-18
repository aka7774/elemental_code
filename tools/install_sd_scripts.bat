@echo off
rem https://dec.2chan.net/up2/src/fu1833259.zip

if exist start.bat goto install

echo start.bat no aru folder ni oitene ;-;
pause>null
exit

:install
SET PATH=%PATH%;%cd%\stable-diffusion-webui\venv\Lib\site-packages\torch\lib
SET PYTHON=%cd%\Python310\Python.exe
SET GIT=%cd%\PortableGit\bin\git.exe

"%GIT%" clone https://github.com/kohya-ss/sd-scripts.git
"%GIT%" clone https://github.com/derrian-distro/LoRA_Easy_Training_Scripts.git
copy /y .\LoRA_Easy_Training_Scripts\*.py .\sd-scripts
cd sd-scripts

"%PYTHON%" -m venv venv

SET PYTHON=%cd%\venv\Scripts\Python.exe

"%PYTHON%" -m pip install torch==1.12.1+cu116 torchvision==0.13.1+cu116 --extra-index-url https://download.pytorch.org/whl/cu116
"%PYTHON%" -m pip install --upgrade -r requirements.txt
"%PYTHON%" -m pip install -U -I --no-deps https://github.com/C43H66N12O12S2/stable-diffusion-webui/releases/download/f/xformers-0.0.14.dev0-cp310-cp310-win_amd64.whl

copy /y .\bitsandbytes_windows\*.dll .\venv\Lib\site-packages\bitsandbytes\
copy /y .\bitsandbytes_windows\cextension.py .\venv\Lib\site-packages\bitsandbytes\cextension.py
copy /y .\bitsandbytes_windows\main.py .\venv\Lib\site-packages\bitsandbytes\cuda_setup\main.py

echo. >config.txt
echo. >>config.txt
echo. >>config.txt
echo. >>config.txt
echo. >>config.txt
echo. >>config.txt
echo ^1>>config.txt

%cd%\venv\Scripts\accelerate.exe config < config.txt

del config.txt

cd ..

echo @echo off>start_lora_train_popup.bat
echo set cpu=^4>>start_lora_train_popup.bat
echo cd /d "%cd%\sd-scripts">>start_lora_train_popup.bat
echo SET PATH=%%PATH%%;%cd%\stable-diffusion-webui\venv\Lib\site-packages\torch\lib>>start_lora_train_popup.bat
echo "%cd%\sd-scripts\venv\Scripts\accelerate.exe" launch --num_cpu_threads_per_process %%cpu%% lora_train_popup.py>>start_lora_train_popup.bat
echo pause>>start_lora_train_popup.bat

echo Done!
pause
