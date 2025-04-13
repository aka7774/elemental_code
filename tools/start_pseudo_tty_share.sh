#!/bin/bash

# --- 設定 ---
# BASIC認証のユーザー名とパスワードを環境変数から取得するか、ここで直接設定します。
# 環境変数で設定する場合: export GRADIO_USERNAME="your_user" && export GRADIO_PASSWORD="your_pass"
# ここで直接設定する場合:
# DEFAULT_USERNAME="user"
# DEFAULT_PASSWORD="password"

# --- BASIC認証情報の確認 ---
# 環境変数 GRADIO_USERNAME, GRADIO_PASSWORD を優先
USERNAME=${GRADIO_USERNAME}
PASSWORD=${GRADIO_PASSWORD}

# 環境変数が設定されていない場合、デフォルト値を使用 (もしあれば)
# if [ -z "$USERNAME" ] && [ -n "$DEFAULT_USERNAME" ]; then
#   USERNAME=$DEFAULT_USERNAME
# fi
# if [ -z "$PASSWORD" ] && [ -n "$DEFAULT_PASSWORD" ]; then
#   PASSWORD=$DEFAULT_PASSWORD
# fi

# それでも設定されていない場合は、ユーザーに入力を促す
if [ -z "$USERNAME" ]; then
  read -p "Enter Gradio Username: " USERNAME
  if [ -z "$USERNAME" ]; then
    echo "Error: Username cannot be empty."
    exit 1
  fi
fi

if [ -z "$PASSWORD" ]; then
  read -sp "Enter Gradio Password: " PASSWORD
  echo #改行用
  if [ -z "$PASSWORD" ]; then
    echo "Error: Password cannot be empty."
    exit 1
  fi
fi

echo "Using Username: $USERNAME"
# パスワードは表示しない

# --- 仮想環境のセットアップ & 依存関係のインストール ---
echo "Setting up virtual environment..."
python3 -m venv venv_pseudo_tty
if [ $? -ne 0 ]; then
    echo "Error: Failed to create virtual environment. Make sure python3 and venv are installed."
    exit 1
fi

echo "Activating virtual environment..."
source venv_pseudo_tty/bin/activate

echo "Installing Gradio..."
pip install gradio
if [ $? -ne 0 ]; then
    echo "Error: Failed to install Gradio."
    deactivate
    exit 1
fi

# --- Gradioアプリケーションコード (app.py) ---
echo "Creating Gradio app file (app.py)..."
cat << EOF > app.py
import gradio as gr
import subprocess
import os
import shlex # コマンドライン引数のパースに使う

# --- 環境変数から認証情報を取得 ---
# シェルスクリプトからエクスポートされたものを読み込む
auth_username = os.environ.get("GRADIO_USERNAME_EXPORT")
auth_password = os.environ.get("GRADIO_PASSWORD_EXPORT")

if not auth_username or not auth_password:
    print("Error: BASIC auth credentials not found in environment variables.")
    print("Please set GRADIO_USERNAME_EXPORT and GRADIO_PASSWORD_EXPORT.")
    # 必要に応じてデフォルト値を設定するか、ここで終了させる
    # exit(1) # or set defaults like:
    # auth_username = "default_user"
    # auth_password = "default_pass"
    # For this script, we rely on the shell script setting them.

auth_credentials = (auth_username, auth_password)

# --- コマンド実行関数 ---
def execute_command(command_str):
    """
    受け取ったコマンド文字列をサーバーで実行し、
    stdoutとstderrを結合して返す。
    """
    if not command_str:
        return "[System] No command entered."

    # セキュリティのため、複雑なシェル機能（パイプ、リダイレクトなど）は
    # 基本的にそのままでは期待通りに動かない可能性があります。
    # shlex.splitを使うと、より安全に引数を分割できますが、
    # シェルそのものの機能を使いたい場合は shell=True が必要です。
    # ここでは、ユーザーがシェルコマンドを直接入力することを想定し、
    # shell=True を使いますが、セキュリティリスクに注意してください。
    print(f"Executing command: {command_str}")
    try:
        # shell=True を使用すると、シェル経由でコマンドが実行される
        # これにより、cdなどのシェルの組み込みコマンドも（ある程度）動作するが、
        # サブプロセス内で完結するため、次のコマンド実行時には元のディレクトリに戻る。
        # また、セキュリティリスクが高まる点に注意。
        result = subprocess.run(
            command_str,
            shell=True,
            capture_output=True,
            text=True,
            encoding='utf-8', # 文字化け対策
            timeout=60 # タイムアウトを設定（秒）
        )

        output = ""
        if result.stdout:
            output += f"--- stdout ---\n{result.stdout.strip()}\n"
        if result.stderr:
            # stderrがない場合でもセクションが見やすいように区切りを入れる
            if result.stdout:
                 output += "\n"
            output += f"--- stderr ---\n{result.stderr.strip()}\n"

        if not result.stdout and not result.stderr:
             output += "[System] Command produced no output (stdout/stderr)."

        # 終了コードも表示するとデバッグに役立つ
        output += f"\n--- exit code: {result.returncode} ---"

        return output

    except subprocess.TimeoutExpired:
        return f"[Error] Command timed out after 60 seconds: {command_str}"
    except Exception as e:
        return f"[Error] Failed to execute command: {command_str}\n{type(e).__name__}: {e}"

# --- Gradioインターフェース定義 ---
# Textboxを使ったシンプルなインターフェース
# CSSで見た目を調整することも可能
# with gr.Blocks(css=".gradio-container { font-family: monospace; }") as demo: # フォント変更例
with gr.Blocks(title="Pseudo TTY") as demo:
    gr.Markdown("# Pseudo TTY Server\nEnter commands to execute on the server.")

    # 出力表示用のTextbox (複数行、読み取り専用)
    output_display = gr.Textbox(
        label="Output (stdout/stderr)",
        lines=20, # 表示行数を増やす
        max_lines=40,
        interactive=False, # ユーザーが編集できないようにする
        show_copy_button=True,
    )

    # コマンド入力用のTextbox (単一行)
    command_input = gr.Textbox(
        label="Command Input",
        placeholder="e.g., ls -l, pwd, echo 'Hello'",
        show_label=False, # ラベルを非表示にしてシンプルに
    )

    # Enterキーまたはボタンクリックで実行
    command_input.submit(
        fn=execute_command,
        inputs=[command_input],
        outputs=[output_display]
    )
    # 送信ボタンも配置 (オプション)
    # submit_btn = gr.Button("Run Command")
    # submit_btn.click(fn=execute_command, inputs=command_input, outputs=output_display)

    # クリアボタン (オプション)
    def clear_output():
        return ""
    clear_btn = gr.Button("Clear Output")
    clear_btn.click(fn=clear_output, inputs=None, outputs=output_display)


# --- アプリケーションの起動 ---
if __name__ == "__main__":
    print("Launching Gradio App...")
    print(f"Basic Auth Enabled: User='{auth_username}'")
    print("Access the public URL generated by Gradio.")

    demo.launch(
        server_name="0.0.0.0",  # ローカルネットワーク内の他のデバイスからアクセス可能にする
        share=True,           # Gradio共有リンクを生成する
        auth=auth_credentials,# BASIC認証を有効にする
        # auth_message="Enter credentials to access the Pseudo TTY" # 認証プロンプトのメッセージ(任意)
    )

EOF

# --- Gradioアプリケーションの起動 ---
echo "Starting Gradio server..."
# 認証情報を環境変数としてエクスポートしてPythonスクリプトから読めるようにする
export GRADIO_USERNAME_EXPORT="$USERNAME"
export GRADIO_PASSWORD_EXPORT="$PASSWORD"

# app.py を実行
python -u app.py

# --- クリーンアップ (スクリプト終了時) ---
echo "Deactivating virtual environment..."
deactivate
# シェルスクリプト終了時に仮想環境を削除したい場合は以下のコメントを外す
# echo "Removing virtual environment..."
# rm -rf venv_pseudo_tty

echo "Script finished."
