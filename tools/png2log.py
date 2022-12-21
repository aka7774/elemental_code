import os
from PIL import Image

# 指定されたディレクトリのパス
directory_path = 'C:\SD\png'

# ディレクトリ内のすべてのpngファイルを検索する
for filename in os.listdir(directory_path):
  if filename.endswith('.png'):
    # ファイルパスを作成する
    filepath = os.path.join(directory_path, filename)
    print(filepath)

    # pngファイルを開く
    img = Image.open(filepath)

    # pngファイルからtEXtチャンクを検索する
    if img.text['parameters']:
        # tEXtチャンクのパラメータを取得する
        chunk_parameters = img.text['parameters']

        # tEXtチャンクの内容を出力する
        with open(filepath + '.txt', 'w') as txt_file:
          txt_file.write(chunk_parameters)
