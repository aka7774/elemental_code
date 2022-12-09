# 1111 Sctiptの失敗作
# 生成時に一時的にコマンドラインオプションを変えられないかと思ったけど無理だった

import copy

import modules.scripts as scripts
import gradio as gr

from modules.processing import process_images
from modules.shared import cmd_opts
from modules.sd_models import load_model

class Script(scripts.Script):
    def title(self):
        return "Temporarily change cmd_opts"

    def ui(self, is_img2img):
        lowvram = gr.Checkbox(label="lowvram")
        medvram = gr.Checkbox(label="medvram")
        no_half = gr.Checkbox(label="no-half")
        no_half_vae = gr.Checkbox(label="no-half-vae")
        precision_full = gr.Checkbox(label="precision full")
        
        return [lowvram, medvram, no_half, no_half_vae, precision_full]

    def run(self, p, lowvram, medvram, no_half, no_half_vae, precision_full):
        global cmd_opts

        _cmd_opts = copy.copy(cmd_opts)

        cmd_opts.lowvram = lowvram
        cmd_opts.medvram = medvram
        cmd_opts.no_half = no_half
        cmd_opts.no_half_vae = no_half_vae
        cmd_opts.precision = 'full' if precision_full else 'autocast'

        load_model()
        processed = process_images(p)

        cmd_opts = _cmd_opts

        return processed
