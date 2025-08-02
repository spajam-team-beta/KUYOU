# KUYOU - 黒歴史供養プラットフォーム

匿名で投稿された誰かの「黒歴史」を、みんなの知恵で「最高の思い出」に書き換える、失敗供養プラットフォーム。

## 🎯 コンセプト

誰もが持つ「消し去りたい過去」を、笑いと学びに変えることで価値を再生産し、失敗を恐れずに挑戦できる優しい世界の実現を目指します。

## 🚀 主な機能

### 1. 懺悔の間（黒歴史投稿）
- 匿名で黒歴史を投稿
- 自動生成される匿名ニックネーム
- カテゴリ分類（恋愛、仕事、学生時代など）

### 2. 供養の広場（タイムライン）
- 投稿された黒歴史を閲覧
- 木魚ボタンで供養（いいね）
- カテゴリフィルター・ソート機能

### 3. 智慧の泉（リライト案）
- より良い対応方法を提案
- 建設的なアドバイスの投稿

### 4. 成仏の儀（ベストアンサー）
- 投稿者がベストアンサーを選択
- 選ばれた投稿は「成仏」して完結

### 5. 徳ポイントシステム
- 各アクションでポイント獲得
- ユーザーランキング機能

## 🛠 技術スタック

### Backend
- Ruby 3.2.2
- Rails 7.0.8 (API mode)
- MySQL 8.0
- JWT認証 (devise-jwt)
- Docker & Docker Compose

### iOS
- Swift 5.8+
- SwiftUI
- iOS 15.0+
- URLSession + Combine

## 📦 セットアップ

### 前提条件
- Docker Desktop
- Xcode 14.0+
- Ruby 3.2.2
- MySQL 8.0

### Backend起動手順

```bash
# 1. リポジトリをクローン
git clone [repository-url]
cd KUYOU

# 2. Backendディレクトリへ移動
cd server

# 3. 環境変数ファイルを作成
cp .env.example .env

# 4. Dockerコンテナを起動
docker-compose up -d

# 5. データベースセットアップ
docker-compose exec web rails db:create
docker-compose exec web rails db:migrate

# 6. 動作確認
curl http://localhost:3000/health
```

### iOS起動手順

```bash
# 1. iOSディレクトリへ移動
cd ios

# 2. Xcodeでプロジェクトを開く
open KUYOU.xcodeproj

# 3. シミュレータまたは実機でビルド・実行
# Cmd + R
```

## 📝 API仕様

Backend APIは http://localhost:3000 で起動します。
Swagger UIは http://localhost:8080 でアクセス可能です。

### 主要エンドポイント

| メソッド | パス | 説明 |
|---------|------|------|
| POST | /api/v1/auth/register | ユーザー登録 |
| POST | /api/v1/auth/login | ログイン |
| GET | /api/v1/posts | 投稿一覧取得 |
| POST | /api/v1/posts | 投稿作成 |
| POST | /api/v1/posts/:id/sympathies | 供養追加 |
| POST | /api/v1/posts/:id/replies | リライト案投稿 |

## 🏗 アーキテクチャ

```
┌─────────────────────────────────────────────┐
│              iOS App (SwiftUI)              │
├─────────────────────────────────────────────┤
│  Views │ ViewModels │ Services │ Models    │
└────────┴────────────┴──────────┴───────────┘
                     ↓ HTTPS/JSON
┌─────────────────────────────────────────────┐
│           Rails API (port 3000)             │
├─────────────────────────────────────────────┤
│ Controllers │ Services │ Models │ Routes   │
└─────────────┴──────────┴────────┴──────────┘
                     ↓
┌─────────────────────────────────────────────┐
│             MySQL 8.0 Database              │
└─────────────────────────────────────────────┘
```

## 📂 ディレクトリ構成

```
KUYOU/
├── docs/                    # ドキュメント
│   ├── requirements.md     # 要件定義書
│   ├── design.md          # 詳細設計書
│   └── tasks.md           # タスクリスト
├── ios/                    # iOSアプリ
│   └── KUYOU/
│       ├── Models/        # データモデル
│       ├── Views/         # UI画面
│       ├── ViewModels/    # ビューモデル
│       └── Services/      # API通信など
└── server/                 # Backend API
    ├── app/
    │   ├── controllers/   # APIコントローラー
    │   ├── models/        # データモデル
    │   ├── services/      # ビジネスロジック
    │   └── serializers/   # JSONシリアライザー
    ├── config/           # 設定ファイル
    ├── db/               # データベース関連
    └── docker-compose.yml

```

## 🧪 テスト実行

### Backend

```bash
# RSpecテスト実行
docker-compose exec web rspec

# Rubocop実行
docker-compose exec web rubocop
```

### iOS

```bash
# Xcodeでテスト実行
# Cmd + U
```

## 🚦 開発の流れ

1. **環境構築**: Docker環境とiOS開発環境のセットアップ
2. **API開発**: Rails APIでエンドポイント実装
3. **iOS開発**: SwiftUIで画面実装
4. **統合テスト**: API連携の動作確認
5. **リリース準備**: ドキュメント整備

## 📄 ライセンス

MIT License

## 👥 貢献者

- Backend開発
- iOS開発
- UI/UXデザイン

## 📞 お問い合わせ

issues: https://github.com/[username]/KUYOU/issues