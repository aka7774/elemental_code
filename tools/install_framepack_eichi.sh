#!/bin/bash
set -e # エラーが発生した場合はスクリプトを即座に終了する

# --- 設定 ---
DEFAULT_INSTALL_DIR="/app/framepack"
PYTHON_VERSION="3.10"

# --- ヘルプメッセージの表示 ---
show_help() {
    echo "Usage: $0 [INSTALL_DIRECTORY]"
    echo ""
    echo "UbuntuにFramePack-eichiをインストールします。"
    echo ""
    echo "引数:"
    echo "  INSTALL_DIRECTORY   (オプション) FramePackをインストールするディレクトリを指定します。"
    echo "                      (デフォルト: ${DEFAULT_INSTALL_DIR})"
    echo ""
    echo "例:"
    echo "  ./install.sh"
    echo "  ./install.sh /home/user/my_framepack"
}

# -h または --help が指定された場合はヘルプを表示して終了
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# --- インストール先ディレクトリの設定 ---
INSTALL_DIR=${1:-$DEFAULT_INSTALL_DIR}

# --- 0. 前提条件のチェック ---
echo "--- 0. 前提条件をチェックしています ---"
if ! command -v nvidia-smi &> /dev/null; then
    echo "エラー: NVIDIAドライバがインストールされていません。先にインストールしてください。"
    exit 1
fi
if ! command -v nvcc &> /dev/null; then
    echo "警告: CUDA Toolkit (nvcc)が見つかりません。CUDA Toolkit 12.xが正しくインストールされていることを確認してください。"
fi
if ! command -v python${PYTHON_VERSION} &> /dev/null; then
    echo "エラー: python${PYTHON_VERSION} がインストールされていません。先にインストールしてください。"
    echo "コマンド例: sudo apt-get install python${PYTHON_VERSION} python${PYTHON_VERSION}-dev python${PYTHON_VERSION}-venv"
    exit 1
fi

echo "インストール先: ${INSTALL_DIR}"
echo "このスクリプトはシステムパッケージのインストールにsudoを使用します。"
read -p "続行するにはEnterキーを押してください。キャンセルするにはCtrl+Cを押してください。"

# --- 1. システム依存関係のインストール ---
echo "--- 1. システムの依存関係をインストールしています ---"
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
    git \
    ffmpeg \
    libsm6 \
    libxext6 \
    libgl1 \
    build-essential \
    wget \
    curl

# --- 2. ディレクトリとPython仮想環境(venv)の作成 ---
echo "--- 2. ディレクトリとPython仮想環境を作成しています ---"
mkdir -p "${INSTALL_DIR}"
cd "${INSTALL_DIR}"
# 絶対パスでvenvを作成
python${PYTHON_VERSION} -m venv venv

# venv内のpython/pipのパスを変数化
VENV_PYTHON="${INSTALL_DIR}/venv/bin/python"
VENV_PIP="${INSTALL_DIR}/venv/bin/pip"

# --- 3. Pythonパッケージのインストール ---
echo "--- 3. Pythonパッケージをインストールしています (時間がかかる場合があります) ---"
# pipのアップグレードと基本パッケージ
${VENV_PIP} install --upgrade pip
${VENV_PIP} install packaging wheel setuptools ninja

# PyTorch (CUDA 12.6対応)
echo "PyTorchをインストールしています..."
${VENV_PIP} install torch==2.6.0 torchvision==0.21.0 torchaudio==2.6.0 --index-url https://download.pytorch.org/whl/cu126

# 高速化ライブラリ
echo "高速化ライブラリをインストールしています..."
${VENV_PIP} install xformers==0.0.29.post3 --no-deps --index-url https://download.pytorch.org/whl/cu126 --no-cache-dir
${VENV_PIP} install triton==2.2.0 --no-cache-dir
${VENV_PIP} install -U "huggingface_hub[cli]"
${VENV_PIP} install flash-attn==2.7.4.post1
${VENV_PIP} install sageattention

# その他のパッケージ
${VENV_PIP} install pynvml "jinja2>=3.1.2" peft

# --- 4. FramePackとFramePack-eichiのインストール ---
echo "--- 4. FramePackとFramePack-eichiをセットアップしています ---"
# インストールディレクトリは既にカレントディレクトリになっている
echo "オリジナルのFramePackリポジトリをクローンしています..."
# カレントディレクトリにクローンするため `.` を指定
git clone https://github.com/lllyasviel/FramePack.git .

echo "FramePackの依存関係をインストールしています..."
${VENV_PIP} install -r requirements.txt

echo "FramePack-eichiを適用しています..."
# 一時ディレクトリにクローンしてファイルをコピー
TEMP_EICHI_DIR=$(mktemp -d)
git clone https://github.com/git-ai-code/FramePack-eichi.git "${TEMP_EICHI_DIR}"
cp -rf "${TEMP_EICHI_DIR}/webui/"* .
rm -rf "${TEMP_EICHI_DIR}"

# --- 5. 起動スクリプトと更新スクリプトの作成 ---
echo "--- 5. 起動用と更新用のスクリプトを作成しています ---"

# 起動スクリプト (start.sh)
cat << 'EOF' > start.sh
#!/bin/bash
# このスクリプトはFramePack-eichiのWeb UIを起動します。

# スクリプト自身のディレクトリを取得
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

# 仮想環境を有効化
source "${SCRIPT_DIR}/venv/bin/activate"

# スクリプトのディレクトリへ移動
cd "${SCRIPT_DIR}"

# メインのGradioサーバーをバックグラウンドで起動
echo "demo_gradio.pyをポート7860で起動します..."
python demo_gradio.py --server 0.0.0.0 --port 7860 &
SERVER_PID=$!

# サーバーが起動するまで少し待機
sleep 5

# eichiのサーバーを起動
if [ -f "endframe_ichi.py" ]; then
  echo "endframe_ichi.pyをポート7861で起動します..."
  # start.shに渡された引数をすべてendframe_ichi.pyに渡す
  python endframe_ichi.py --server 0.0.0.0 --port 7861 "$@" &
fi

# サーバーが起動するまで少し待機
sleep 5

# eichiのサーバーを起動
if [ -f "oneframe_ichi.py" ]; then
  echo "oneframe_ichi.pyをポート7862で起動します..."
  # start.shに渡された引数をすべてoneframe_ichi.pyに渡す
  python oneframe_ichi.py --server 0.0.0.0 --port 7862 "$@"
fi

# スクリプト終了時にバックグラウンドのプロセスを終了させる
kill $SERVER_PID
wait $SERVER_PID 2>/dev/null
EOF
chmod +x start.sh

# 更新スクリプト (update.sh)
cat << 'EOF' > update.sh
#!/bin/bash
set -e

echo "--- FramePack-eichiを更新しています ---"

# スクリプト自身のディレクトリを取得
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
cd "${SCRIPT_DIR}"

# 更新用の一時ディレクトリを作成
TEMP_EICHI_DIR=$(mktemp -d)
echo "最新のFramePack-eichiを一時ディレクトリにクローンしています..."
git clone https://github.com/git-ai-code/FramePack-eichi.git "${TEMP_EICHI_DIR}"

echo "更新されたファイルをコピーしています..."
# 新しいファイルで既存のファイルを上書き
cp -rf "${TEMP_EICHI_DIR}/webui/"* .

echo "一時ファイルをクリーンアップしています..."
rm -rf "${TEMP_EICHI_DIR}"

echo "--- 更新が完了しました！ ---"
EOF
chmod +x update.sh

# --- 完了メッセージ ---
echo ""
echo "--- インストールが完了しました！ ---"
echo ""
echo "FramePackを起動するには、以下のコマンドを実行してください:"
echo "cd ${INSTALL_DIR}"
echo "./start.sh"
echo ""
echo "eichiのデフォルト引数は '--lang en --listen' です。"
echo "引数を変更することもできます。例（日本語化）:"
echo "./start.sh --lang ja"
echo ""
echo "今後、FramePack-eichiを最新バージョンに更新するには、以下のコマンドを実行してください:"
echo "cd ${INSTALL_DIR}"
echo "./update.sh"
echo ""