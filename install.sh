#!/bin/bash
set -e

SERVICE_NAME="rclone-gdrive.service"
ENV_NAME=".env"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
INSTALLED_ENV_PATH="${SYSTEMD_USER_DIR}/${ENV_NAME}"
INSTALLED_SERVICE_PATH="${SYSTEMD_USER_DIR}/${SERVICE_NAME}"
FUSE_CONF="/etc/fuse.conf"

echo "🚀 rclone systemd 自動マウントのセットアップを開始します..."

# 1. 環境変数ファイルからローカルマウントフォルダ名を取得してフォルダを作成
if [ -f "${ENV_NAME}" ]; then
    LOCAL_DIR=$(grep -E "^LOCAL_MOUNT_DIR=" "${ENV_NAME}" | cut -d'=' -f2)
    echo "📂 マウント用ディレクトリを作成中: $HOME/${LOCAL_DIR}"
    mkdir -p "$HOME/${LOCAL_DIR}"
else
    echo "⚠️ ${ENV_NAME} が見つかりません。ファイルを確認してください。"
    exit 1
fi

# 2. systemd設定フォルダの作成
mkdir -p "${SYSTEMD_USER_DIR}"

# 3. allow_other を使う場合は fuse.conf の設定を事前確認
if grep -q -- '--allow-other' "${SERVICE_NAME}"; then
    if ! grep -Eq '^[[:space:]]*user_allow_other([[:space:]]*#.*)?$' "${FUSE_CONF}" 2>/dev/null; then
        echo "⚠️ ${SERVICE_NAME} は --allow-other を使いますが、${FUSE_CONF} で user_allow_other が有効ではありません。"
        echo "   ${FUSE_CONF} に user_allow_other を追加またはコメント解除してから再実行してください。"
        exit 1
    fi
fi

# 4. 設定ファイルとサービスファイルをまとめてユーザーディレクトリにコピー
echo "📝 設定ファイルを配置中..."
install -m 644 "${ENV_NAME}" "${INSTALLED_ENV_PATH}"
install -m 644 "${SERVICE_NAME}" "${INSTALLED_SERVICE_PATH}"

# 5. コピーしたunitを検証してから再読込・再起動
echo "🔍 サービス定義を検証中..."
systemd-analyze verify "${INSTALLED_SERVICE_PATH}"

echo "🔄 サービスを再読込・有効化・再起動中..."
systemctl --user daemon-reload
systemctl --user enable "${SERVICE_NAME}"
systemctl --user reset-failed "${SERVICE_NAME}" 2>/dev/null || true
systemctl --user restart "${SERVICE_NAME}"

# 起動時の常時実行を許可
sudo loginctl enable-linger $(whoami)

echo "✅ セットアップが完了しました！"
