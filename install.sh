#!/bin/bash
set -e

SERVICE_NAME="rclone-gdrive.service"
TIMER_NAME="rclone-gdrive.timer"
ENV_NAME=".env"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
INSTALLED_ENV_PATH="${SYSTEMD_USER_DIR}/${ENV_NAME}"
INSTALLED_SERVICE_PATH="${SYSTEMD_USER_DIR}/${SERVICE_NAME}"
INSTALLED_TIMER_PATH="${SYSTEMD_USER_DIR}/${TIMER_NAME}"

echo "🚀 rclone systemd 自動同期(sync)のセットアップを開始します..."

# 1. 環境変数ファイルから同期先フォルダ名を取得してフォルダを作成
if [ -f "${ENV_NAME}" ]; then
    LOCAL_DIR=$(grep -E "^LOCAL_SYNC_DIR=" "${ENV_NAME}" | cut -d'=' -f2)
    if [ -z "${LOCAL_DIR}" ]; then
        echo "⚠️ ${ENV_NAME} に LOCAL_SYNC_DIR が設定されていません。"
        exit 1
    fi
    echo "📂 同期用ディレクトリを作成中: $HOME/${LOCAL_DIR}"
    mkdir -p "$HOME/${LOCAL_DIR}"
else
    echo "⚠️ ${ENV_NAME} が見つかりません。ファイルを確認してください。"
    exit 1
fi

# 2. systemd設定フォルダの作成
mkdir -p "${SYSTEMD_USER_DIR}"

# 3. 設定ファイル・サービス・タイマーをまとめてユーザーディレクトリにコピー
echo "📝 設定ファイルを配置中..."
install -m 644 "${ENV_NAME}" "${INSTALLED_ENV_PATH}"
install -m 644 "${SERVICE_NAME}" "${INSTALLED_SERVICE_PATH}"
install -m 644 "${TIMER_NAME}" "${INSTALLED_TIMER_PATH}"

# 4. コピーしたunitを検証してから再読込
echo "🔍 サービス定義を検証中..."
systemd-analyze verify "${INSTALLED_SERVICE_PATH}"
systemd-analyze verify "${INSTALLED_TIMER_PATH}"

echo "🔄 サービスを再読込・タイマーを有効化中..."
systemctl --user daemon-reload
systemctl --user enable "${TIMER_NAME}"
systemctl --user reset-failed "${SERVICE_NAME}" 2>/dev/null || true
systemctl --user restart "${TIMER_NAME}"

# 5. 初回同期を即時実行（完了を待たずバックグラウンドで進行）
echo "⏳ 初回同期を開始します..."
systemctl --user start --no-block "${SERVICE_NAME}"

# 起動時の常時実行を許可（ログインしていなくてもタイマーが動くように）
sudo loginctl enable-linger "$(whoami)"

echo "✅ セットアップが完了しました！"
echo "   進捗確認: journalctl --user -u ${SERVICE_NAME} -f"
echo "   次回実行: systemctl --user list-timers ${TIMER_NAME}"
