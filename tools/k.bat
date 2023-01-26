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
cd sd-scripts

"%PYTHON%" -m venv venv

SET PYTHON=%cd%\venv\Scripts\Python.exe

"%PYTHON%" -m pip install torch==1.12.1+cu116 torchvision==0.13.1+cu116 --extra-index-url https://download.pytorch.org/whl/cu116
"%PYTHON%" -m pip install --upgrade -r requirements.txt
"%PYTHON%" -m pip install -U -I --no-deps https://github.com/C43H66N12O12S2/stable-diffusion-webui/releases/download/f/xformers-0.0.14.dev0-cp310-cp310-win_amd64.whl

copy /y .\bitsandbytes_windows\*.dll .\venv\Lib\site-packages\bitsandbytes\
copy /y .\bitsandbytes_windows\cextension.py .\venv\Lib\site-packages\bitsandbytes\cextension.py
copy /y .\bitsandbytes_windows\main.py .\venv\Lib\site-packages\bitsandbytes\cuda_setup\main.py

rem bitsadmin /transfer ckpt https://huggingface.co/JosephusCheung/ACertainModel/resolve/main/ACertainModel-half.ckpt %cd%\ACertainModel-half.ckpt

bitsadmin /transfer train https://huggingface.co/datasets/aka7774/zunko/resolve/main/7_Zunko%%201girl.zip %cd%\7_Zunko_1girl.zip
call powershell -command "Expand-Archive -Force 7_Zunko_1girl.zip -DestinationPath %cd%\train"

bitsadmin /transfer reg_data https://huggingface.co/datasets/aka7774/zunko/resolve/main/1_1girl.zip %cd%\1_1girl.zip
call powershell -command "Expand-Archive -Force 1_1girl.zip -DestinationPath %cd%\reg_data"

rem set PATH=%PATH%;C:\SD\stable-diffusion-webui\venv\Lib\site-packages\torch\lib
set PYTORCH_CUDA_ALLOC_CONF=garbage_collection_threshold:0.6,max_split_size_mb:24

%cd%\venv\Scripts\accelerate config

%cd%\venv\Scripts\accelerate launch --num_cpu_threads_per_process 8 %cd%\train_network.py ^
   --pretrained_model_name_or_path=%cd%\ACertainModel-half.ckpt ^
   --train_data_dir=%cd%\train ^
   --output_dir=%cd%\output ^
   --output_name=Zunko-lora ^
   --reg_data_dir=%cd%\reg_data ^
   --prior_loss_weight=1.0 ^
   --resolution=768 ^
   --train_batch_size=1 ^
   --learning_rate=3e-6 ^
   --max_data_loader_n_workers=8 ^
   --max_train_epochs=5 ^
   --gradient_checkpointing ^
   --use_8bit_adam ^
   --mixed_precision=fp16 ^
   --save_precision=fp16 ^
   --logging_dir=%cd%\logs ^
   --enable_bucket ^
   --min_bucket_reso=384 ^
   --max_bucket_reso=1024 ^
   --save_model_as=safetensors ^
   --clip_skip=2 ^
   --seed=17283378 ^
   --lr_scheduler=cosine ^
   --caption_extension=txt ^
   --color_aug ^
   --network_dim=48 ^
   --network_module=networks.lora

pause
