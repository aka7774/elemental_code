import os
import glob
from pathlib import Path
from typing import List
from PIL import Image
from zlib import crc32

def tEXt(key: str, val: str) -> bytes:
    """PNG tEXt chunkを作成する
    
    Args:
        key (str): tEXtのキー
        val (str): tEXtの値
    
    Returns:
        bytes: PNG tEXt chunk
    """
    str = key + "\0" + val
    return (len(str)).to_bytes(4, 'big') + b'tEXt' + str.encode() + (crc32(b'tEXt' + str.encode())).to_bytes(4, 'big')

src = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'txt', '*.txt')
is_overwrite = True
ignore_files = []  # ['0005', '0006', '0012', '0039', '0041']

for path in glob.glob(src):
    fn = Path(path).stem
    print(fn)
    if fn in ignore_files:
        continue

    dst = os.path.join(os.path.dirname(os.path.dirname(path)), 'png',fn + '.png')
    if not is_overwrite and os.path.exists(dst):
        continue

    with open(path, 'r') as f:
        txt = f.read()

    im = Image.new('RGB', (1, 1))
    im.save(dst)
    with open(dst, 'r+b') as f:
        png = f.read()

    text = tEXt('parameters', txt)
    iend = bytes.fromhex('0000000049454e44ae426082')
    png = png.replace(iend, text + iend)

    with open(dst, 'w+b') as f:
        f.write(png)