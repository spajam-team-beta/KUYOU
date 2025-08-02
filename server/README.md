# KUYOU Server - Rails API

黒歴史リバイバル供養アプリのバックエンドAPI

## 技術スタック

- Ruby on Rails (API mode)
- Docker
- Jbuilder (JSON整形)

## アーキテクチャ

### ディレクトリ構成

```
app/
├── controllers/     # APIエンドポイント
├── models/         # ActiveRecordモデル
├── services/       # ビジネスロジック層
├── views/          # Jbuilderテンプレート
└── ...

lib/
└── utils/          # 汎用処理・ヘルパー
```

### 設計方針

- **Controller**: HTTPリクエスト/レスポンスの処理に特化
- **Service層**: ビジネスロジックを集約し、Controllerの肥大化を防止
- **lib層**: ビジネスロジックに依存しない汎用的な処理
- **Jbuilder**: APIレスポンスのJSON整形

## セットアップ

### 必要な環境

- Docker
- Docker Compose

### 起動方法

```bash
# コンテナのビルドと起動
docker-compose up --build

# データベースのセットアップ
docker-compose exec web rails db:create
docker-compose exec web rails db:migrate
```

### 開発用コマンド

```bash
# Railsコンソール
docker-compose exec web rails console

# テスト実行
docker-compose exec web rspec

# データベースのリセット
docker-compose exec web rails db:reset
```

## API仕様

APIエンドポイントの詳細は別途ドキュメントを参照してください。
