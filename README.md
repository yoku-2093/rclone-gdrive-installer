# rclone Google Drive Installer (systemd)

Linuxの `systemd` ユーザーモードを利用し、Raspberry Pi等で定期的にGoogle ドライブの内容をローカルフォルダへ **同期(ダウンロード)** する環境構築スクリプトです。

`rclone mount` と違い、参照時にネットワークIOが発生しないため、ローカルディスク速度でアクセスできます。代わりに対象データの実体分のディスク容量を消費します。

## 🌐 サポートするプラットフォーム
- **Raspberry Pi OS** (Bullseye / Bookworm 以降、32bit/64bit両対応)
- **Ubuntu** (20.04 LTS 以降)
- **Debian** (11 / 12 以降)


## 1. 必要なアプリのインストール
echo "📦 依存パッケージをインストール中..."
sudo apt update && sudo apt install -y rclone


## 📋 2. 事前準備 (rcloneの初期設定)

このスクリプトを実行する前に、Googleアカウントとの連携設定（認証トークンの取得）を完了させておく必要があります。

ターミナルを開き、以下の手順を実行してください。

```bash
rclone config
```

また.envを作成して必要に応じて編集してください
```bash
cp .env.sample .env
nano .env
```

### 💡 対話画面での入力手順
1. **`n/s/q>`** ➔ **`n`** (新規作成) を入力してEnter
2. **`name>`** ➜ **`gdrive`** と入力してEnter（※.env の `GDRIVE_DIR` と合わせてください）
3. **クラウド一覧** ➜ **`google drive`** を探して入力（または対応する番号を入力）してEnter
4. **`client_id / client_secret>`** ➜ 何も入力せず **空欄のままEnter** を2回押す
5. **`scope>`** ➜ **`drive.readonly`** (読み込み専用) を推奨。対応する番号を入力してEnter
6. **`Edit advanced config?>`** ➜ **`n`** を入力してEnter
7. **`Use auto config?>`** ➜ **`y`** を入力してEnter
   - 自動的にブラウザが起動します。Googleアカウントにログインし、アクセスを**許可**してください。
8. 最後に確認が出るので **`y`** を入力してEnter
9. メニューに戻ったら **`q`** を入力して終了

---

## 🚀 3. 使い方 (インストール)

事前準備が終わったら、以下のコマンドで一発構築を行います。

```bash
git clone https://github.com/yoku2093/rclone-gdrive-installer
cd rclone-gdrive-installer
./install.sh
```

## 🔍 4. 状態の確認と停止

### 動作確認
同期タイマーの状態と次回実行時刻は以下で確認できます。
```bash
systemctl --user list-timers rclone-gdrive.timer
```

同期処理(本体)の状態・ログは以下で確認できます。
```bash
systemctl --user status rclone-gdrive.service
journalctl --user -u rclone-gdrive.service -f
```

### 手動で今すぐ同期
```bash
systemctl --user start rclone-gdrive.service
```

### 停止（定期同期を止める）
```bash
systemctl --user stop rclone-gdrive.timer
```

### 同期間隔の変更
`rclone-gdrive.timer` の `OnUnitActiveSec`(デフォルト15分)を編集し、再度 `./install.sh` を実行してください。

