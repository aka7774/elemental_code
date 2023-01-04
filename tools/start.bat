@echo off 
set PATH=;H:\Stable Diffusion\elemental_code\tools\\python310\Scripts;H:\Stable Diffusion\elemental_code\tools\PortableGit\bin 
set PYTHON=H:\Stable Diffusion\elemental_code\tools\python310\python.exe 
set GIT=H:\Stable Diffusion\elemental_code\tools\PortableGit\bin\git.exe 
set VENV_DIR= 
set COMMANDLINE_ARGS=--xformers 
cd H:\Stable Diffusion\elemental_code\tools\stable-diffusion-webui 
call webui.bat 
