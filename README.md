# rclone Google Photos Installer (systemd)

Linuxの `systemd` ユーザーモードを利用し、Raspberry Pi等の起動時に自動でGoogle ドライブをローカルフォルダへマウントする環境構築スクリプトです。

## 🌐 サポートするプラットフォーム
- **Raspberry Pi OS** (Bullseye / Bookworm 以降、32bit/64bit両対応)
- **Ubuntu** (20.04 LTS 以換以降)
- **Debian** (11 / 12 以降)


## 1. 必要なアプリのインストール
echo "📦 依存パッケージをインストール中..."
sudo apt update && sudo apt install -y rclone fuse3

### FUSE の追加設定

このプロジェクトの service は `--allow-other` を使うため、環境によっては `/etc/fuse.conf` で `user_allow_other` を有効にする必要があります。

現在の設定確認:

```bash
grep -n 'user_allow_other' /etc/fuse.conf
```

`#user_allow_other` のようにコメントアウトされている場合は、以下のように有効化してください。

```bash
sudo nano /etc/fuse.conf
```

設定内容:

```text
user_allow_other
```

この設定が無いと、`rclone mount` が `--allow-other` 付きで起動するときに失敗することがあります。


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
2. **`name>`** ➔ **`gphotos`** と入力してEnter（※この名前を変更するとスクリプトが動きません）
3. **クラウド一覧** ➔ **`google photos`** を探して入力（または対応する番号を入力）してEnter
4. **`client_id / client_secret>`** ➔ 何も入力せず **空欄のままEnter** を2回押す
5. **`read_only>`** ➔ **`true`** を入力してEnter (安全のため読み込み専用を推奨)
6. **`Edit advanced config?>`** ➔ **`n`** を入力してEnter
7. **`Use auto config?>`** ➔ **`y`** を入力してEnter
   - 自動的にブラウザが起動します。Googleアカウントにログインし、アクセスを**許可**してください。
   - ⚠️ **注意:** 認証画面で「Googleフォトのライブラリの表示・管理」のチェックボックスが表示されたら、必ず**チェックを入れてから**続行してください。
8. 最後に確認が出るので **`y`** を入力してEnter
9. メニューに戻ったら **`q`** を入力して終了

---

## 🚀 3. 使い方 (インストール)

事前準備が終わったら、以下のコマンドで一発構築を行います。

```bash
git clone https://github.com/yoku2093/rclone-gdrive-installer
cd rclone-gphotos-installer
./install.sh
```

## 🔍 4. 状態の確認と停止

### 動作確認
正しく動いているかは以下のコマンドで確認できます。
```bash
sudo systemctl status rclone-gdrive.service
```

### 停止
停止する場合は以下のコマンドで確認できます。
```bash
sudo systemctl stop rclone-gdrive.service
```

