# 元素法典写経(ローカル用)


## ファイル

- README.md あそびかた
- changelog.md 各ファイルの編集内容
- names.txt 番号と名前の対応表。Notepad++などのUnicode対応エディタで開いてください。
- txt/ 画像を出力した時に吐かれるparamters文字列
- png/ PNG Infoに投げる用の画像
- json/ Generate from json用


## あそびかた

手編集のとき
1. txtを開いてすべて選択してコピー
2. 1111 の txt2img の Prompt に貼り付け
3. 右側にある左下矢印アイコンを押す
4. Generate ボタンを押す

画像を使う方法(廃止するかも)
1. 1111 の PNG Info タブを開いて画像をドロップする
2. Send to txt2imgを押す
3. txt2imgタブを開いて Generate ボタンを押す

自動で出したいとき
1. Generate from jsonをインストールする
2. webui直下のpromptsにjsonをコピーする
3. txt2imgの左下のScriptで「Generate from json」を選択
4. 右上のGenerate


### Generate from json

https://github.com/aka7774/generate_from_json


## 謝辞

- 元素法典(第1巻)
https://docs.qq.com/doc/DWHl3am5Zb05QbGVs

- 元素法典第1.5巻
https://docs.qq.com/doc/DWGh4QnZBVlJYRkly

- 元素法典第2巻
https://docs.qq.com/doc/DWEpNdERNbnBRZWNL

- 元素法典第2.5巻
https://docs.qq.com/doc/DWHFOd2hDSFJaamFm

- 배경학개론(背景技術の概論)
https://docs.google.com/document/d/11sb3AOCE4B5CZeMELNL8PwWoIae2jkrdcz-UEJw_Ayc

- nai2sd-Converter
https://github.com/AUTOMATIC-gassy/nai2sd-Converter

- Random Choice Script
https://github.com/hanarchy/ramdom_generation_from_json

- Notepad++ Portable
https://portableapps.com/apps/development/notepadpp_portable
