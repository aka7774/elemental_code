set PYTORCH_CUDA_ALLOC_CONF=garbage_collection_threshold:0.6,max_split_size_mb:24

%cd%\sd-scripts\venv\Scripts\accelerate launch --num_cpu_threads_per_process 1 --mixed_precision=fp16 %cd%\train_network.py ^
   --pretrained_model_name_or_path=%cd%\ACertainModel-half.ckpt ^
   --train_data_dir=%cd%\train ^
   --output_dir=%cd%\output ^
   --output_name=Zunko-lora ^
   --reg_data_dir=%cd%\reg_data ^
   --prior_loss_weight=1.0 ^
   --resolution=768 ^
   --train_batch_size=1 ^
   --learning_rate=3e-6 ^
   --max_data_loader_n_workers=12 ^
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
   --network_dim=128 ^
   --network_module=networks.lora

pause
