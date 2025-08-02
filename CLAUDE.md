# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

KUYOUは「黒歴史供養プラットフォーム」として、匿名で投稿された失敗体験を、コミュニティの知恵で価値ある学びに変えるアプリケーションです。

### Architecture

- **iOS App**: SwiftUI ベースのネイティブアプリ
- **Backend**: Rails API (API mode)
- **Database**: MySQL 8.0
- **Container**: Docker & Docker Compose

## Common Development Commands

### Server Development

```bash
# サーバー起動（初回）
cd server
docker-compose up --build

# データベースセットアップ
docker-compose exec web rails db:create
docker-compose exec web rails db:migrate

# サーバー起動（2回目以降）
docker-compose up

# Railsコンソール
docker-compose exec web rails console

# テスト実行
docker-compose exec web rspec

# データベースリセット
docker-compose exec web rails db:reset

# マイグレーション作成
docker-compose exec web rails generate migration [MigrationName]

# モデル作成
docker-compose exec web rails generate model [ModelName]

# コントローラー作成
docker-compose exec web rails generate controller [ControllerName]
```

### iOS Development

- Xcode でプロジェクトを開く: `ios/KUYOU.xcodeproj`
- ビルド＆実行: Cmd+R
- テスト実行: Cmd+U

## Key Project Structure

### Server Architecture
- **Controllers**: APIエンドポイントの定義 (`app/controllers/`)
- **Models**: データモデル (`app/models/`)
- **Services**: ビジネスロジック層 (`app/services/`)
- **Views**: Jbuilder JSONテンプレート (`app/views/`)

### API Design Principles
1. RESTful API設計
2. Controller は薄く、ビジネスロジックは Service層へ
3. 汎用的な処理は `lib/utils/` へ

## Development Context

### 必須機能（MVP）
1. ユーザー認証・登録
2. 黒歴史投稿（懺悔の間）
3. タイムライン表示（供養の広場）
4. 供養機能（木魚ボタン）
5. リライト案投稿（智慧の泉）
6. ベストアンサー認定（成仏の儀）
7. 徳ポイントシステム

### 技術的制約
- Ruby 3.2.2
- Rails 7.0.8+
- MySQL 8.0
- Docker必須
- Swagger UI (port 8080)

## Important Notes

- 匿名性の保持が重要な要件
- 不適切コンテンツ対策が必要
- 徳ポイントの配分ルールは要件定義書参照