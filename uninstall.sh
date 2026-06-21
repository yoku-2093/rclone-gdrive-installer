#!/bin/bash
set -e

SERVICE_NAME="rclone-gdrive.service"
TIMER_NAME="rclone-gdrive.timer"
ENV_NAME=".env"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"

echo "🗑️ アンインストールを開始します..."

# 1. タイマーとサービスを停止・無効化
systemctl --user disable --now "${TIMER_NAME}" 2>/dev/null || true
systemctl --user stop "${SERVICE_NAME}" 2>/dev/null || true
systemctl --user reset-failed "${TIMER_NAME}" 2>/dev/null || true
systemctl --user reset-failed "${SERVICE_NAME}" 2>/dev/null || true

# 2. ファイルの物理削除（同期済みのローカルデータは残します）
rm -f "${SYSTEMD_USER_DIR}/${TIMER_NAME}"
rm -f "${SYSTEMD_USER_DIR}/${SERVICE_NAME}"
rm -f "${SYSTEMD_USER_DIR}/${ENV_NAME}"
systemctl --user daemon-reload

echo "✅ アンインストールが完了しました！"
echo "   同期されたローカルフォルダはそのまま残っています。不要な場合は手動で削除してください。"
