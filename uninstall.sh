#!/bin/bash
set -e

SERVICE_NAME="rclone-gdrive.service"
ENV_NAME=".env"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"

if command -v fusermount3 >/dev/null 2>&1; then
    FUSERMOUNT_BIN="fusermount3"
else
    FUSERMOUNT_BIN="fusermount"
fi

echo "🗑️ アンインストールを開始します..."

# 1. サービス環境ファイルからマウント先を特定して解除
if [ -f "${SYSTEMD_USER_DIR}/${ENV_NAME}" ]; then
    LOCAL_DIR=$(grep -E "^LOCAL_MOUNT_DIR=" "${SYSTEMD_USER_DIR}/${ENV_NAME}" | cut -d'=' -f2)
    FULL_PATH="$HOME/${LOCAL_DIR}"
    
    systemctl --user disable --now "${SERVICE_NAME}" 2>/dev/null || true
    systemctl --user reset-failed "${SERVICE_NAME}" 2>/dev/null || true
    
    "${FUSERMOUNT_BIN}" -u "${FULL_PATH}" 2>/dev/null || true
    sudo umount -f "${FULL_PATH}" 2>/dev/null || true
fi

# 2. ファイルの物理削除
rm -f "${SYSTEMD_USER_DIR}/${SERVICE_NAME}"
rm -f "${SYSTEMD_USER_DIR}/${ENV_NAME}"
systemctl --user daemon-reload
systemctl --user reset-failed "${SERVICE_NAME}" 2>/dev/null || true

echo "✅ アンインストールが完了しました！"
