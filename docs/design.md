# 詳細設計書 - KUYOU (黒歴史供養プラットフォーム)

## 1. アーキテクチャ概要

### 1.1 システム構成図

```
┌─────────────────────────────────────────────────────────────┐
│                     iOS App (SwiftUI)                       │
├─────────────────────────────────────────────────────────────┤
│  Views          │  ViewModels        │  Services           │
│  - LoginView    │  - AuthViewModel   │  - APIService       │
│  - TimelineView │  - PostViewModel   │  - AuthService      │
│  - PostView     │  - TimelineVM      │  - CacheService     │
│  - ProfileView  │  - ProfileVM       │  - SoundService     │
└─────────────────┼────────────────────┼─────────────────────┘
                   │                    │
                   │    HTTPS/JSON      │
                   └────────────────────┘
                            │
                   ┌────────▼────────┐
                   │   Nginx (80)    │
                   └────────┬────────┘
                            │
        ┌───────────────────┴───────────────────┐
        │         Rails API (3000)              │
        ├───────────────────────────────────────┤
        │  Controllers  │  Services  │  Models │
        │  - AuthAPI    │  - Auth    │  - User │
        │  - PostsAPI   │  - Points  │  - Post │
        │  - RepliesAPI │  - Notify  │  - Reply│
        └──────────────┴────────────┴──────────┘
                            │
                   ┌────────▼────────┐
                   │  MySQL 8.0      │
                   └─────────────────┘
```

### 1.2 技術スタック

#### iOS App
- 言語: Swift 5.8+
- UI Framework: SwiftUI
- 最小対応OS: iOS 18.0
- ネットワーク: URLSession + Combine
- データ永続化: UserDefaults + Keychain
- 依存管理: Swift Package Manager

#### Backend
- 言語: Ruby 3.2.2
- Framework: Rails 7.0.8 (API mode)
- データベース: MySQL 8.0
- 認証: JWT (devise-jwt)
- APIドキュメント: Swagger/OpenAPI 3.0
- キャッシュ: Rails.cache (Memory Store)
- ジョブキュー: Active Job (async adapter)

#### インフラ
- コンテナ: Docker & Docker Compose
- Webサーバー: Nginx (リバースプロキシ)
- 開発ツール: Rubocop, RSpec, SwiftLint

## 2. コンポーネント設計

### 2.1 コンポーネント一覧

#### iOS側コンポーネント

| コンポーネント名 | 責務 | 依存関係 |
|---|---|---|
| AuthService | 認証管理、トークン保存 | KeychainHelper, APIService |
| APIService | API通信の基盤 | NetworkMonitor |
| PostService | 投稿関連の操作 | APIService, CacheService |
| TimelineService | タイムライン取得・更新 | APIService, CacheService |
| PointsService | 徳ポイント管理 | APIService |
| SoundService | 木魚音の再生 | AVFoundation |
| CacheService | データキャッシュ | UserDefaults |

#### Backend側コンポーネント

| コンポーネント名 | 責務 | 依存関係 |
|---|---|---|
| Auth::RegisterService | ユーザー登録 | User |
| Auth::LoginService | ログイン処理・JWT発行 | User, JWT |
| Posts::CreateService | 投稿の作成 | Post, Utils::NicknameGenerator |
| Posts::ResolveService | 投稿の成仏処理 | Post, Points::CalculateService |
| Sympathies::CreateService | 供養の追加 | Sympathy, Points::CalculateService |
| Replies::CreateService | リライト案の作成 | Reply, Notifications::CreateService |
| Replies::SelectBestService | ベストアンサー選択 | Reply, Posts::ResolveService |
| Points::CalculateService | 徳ポイントの計算・付与 | UserPoint |
| Notifications::CreateService | 通知の作成 | Notification |
| ContentFilters::ValidateService | 不適切コンテンツ検出 | Utils::NGWordFilter |

### 2.2 各コンポーネントの詳細

#### AuthService (iOS)

- **目的**: ユーザー認証とセッション管理
- **公開インターフェース**:
```swift
protocol AuthServiceProtocol {
    func login(email: String, password: String) async throws -> User
    func register(email: String, password: String) async throws -> User
    func logout() async throws
    func refreshToken() async throws -> String
    var isAuthenticated: Bool { get }
    var currentUser: User? { get }
}
```
- **内部実装方針**:
  - JWTトークンをKeychainに安全に保存
  - 自動トークンリフレッシュ機構
  - オフライン時のエラーハンドリング

#### Posts::CreateService (Backend)

- **目的**: 黒歴史投稿の作成
- **公開インターフェース**:
```ruby
module Posts
  class CreateService
    def self.call(user:, content:, category:)
      new(user: user, content: content, category: category).call
    end

    private

    def initialize(user:, content:, category:)
      @user = user
      @content = content
      @category = category
    end

    def call
      validate_content!
      create_post_with_nickname
      calculate_points
    end

    def validate_content!
      ContentFilters::ValidateService.call(content: @content)
    end

    def create_post_with_nickname
      # 匿名ニックネーム自動生成と投稿作成
    end

    def calculate_points
      Points::CalculateService.call(user: @user, action: :post_created)
    end
  end
end
```

#### Sympathies::CreateService (Backend)

- **目的**: 供養（いいね）の追加
- **公開インターフェース**:
```ruby
module Sympathies
  class CreateService
    def self.call(post:, user:)
      new(post: post, user: user).call
    end

    private

    def initialize(post:, user:)
      @post = post
      @user = user
    end

    def call
      return { error: '既に供養済みです' } if already_sympathized?

      create_sympathy
      update_post_counter
      calculate_points
    end

    def already_sympathized?
      # 重複チェック
    end

    def create_sympathy
      # 供養レコード作成
    end

    def update_post_counter
      # カウンター更新
    end

    def calculate_points
      Points::CalculateService.call(user: @user, action: :sympathy_given)
      Points::CalculateService.call(user: @post.user, action: :sympathy_received)
    end
  end
end
```

## 3. データベース設計

### 3.1 ER図

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   users     │     │   posts     │     │  replies    │
├─────────────┤     ├─────────────┤     ├─────────────┤
│ id          │1───*│ id          │1───*│ id          │
│ email       │     │ user_id     │     │ post_id     │
│ password    │     │ nickname    │     │ user_id     │
│ total_points│     │ content     │     │ content     │
│ created_at  │     │ category    │     │ is_best     │
└─────────────┘     │ status      │     │ created_at  │
                    │ created_at  │     └─────────────┘
                    └─────────────┘
                           │1
                           │
                           │*
                    ┌─────────────┐
                    │ sympathies  │
                    ├─────────────┤
                    │ id          │
                    │ post_id     │
                    │ user_id     │
                    │ created_at  │
                    └─────────────┘
```

### 3.2 テーブル定義

#### users
```sql
CREATE TABLE users (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  email VARCHAR(255) UNIQUE NOT NULL,
  encrypted_password VARCHAR(255) NOT NULL,
  total_points INT DEFAULT 0,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL,
  INDEX idx_email (email)
);
```

#### posts
```sql
CREATE TABLE posts (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  nickname VARCHAR(50) NOT NULL,
  content TEXT NOT NULL,
  category VARCHAR(20) NOT NULL,
  status ENUM('active', 'resolved') DEFAULT 'active',
  sympathy_count INT DEFAULT 0,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id),
  INDEX idx_user_id (user_id),
  INDEX idx_status_created (status, created_at)
);
```

## 4. APIインターフェース

### 4.1 認証API

#### POST /api/v1/auth/register
```json
// Request
{
  "email": "user@example.com",
  "password": "password123"
}

// Response
{
  "user": {
    "id": 1,
    "email": "user@example.com",
    "total_points": 0
  },
  "token": "eyJhbGciOiJIUzI1NiJ9..."
}
```

#### POST /api/v1/auth/login
```json
// Request
{
  "email": "user@example.com",
  "password": "password123"
}

// Response
{
  "user": {
    "id": 1,
    "email": "user@example.com",
    "total_points": 150
  },
  "token": "eyJhbGciOiJIUzI1NiJ9..."
}
```

### 4.2 投稿API

#### GET /api/v1/posts
```json
// Query Parameters
// ?page=1&per_page=10&category=love&sort=popular

// Response
{
  "posts": [
    {
      "id": 1,
      "nickname": "迷える子羊#123",
      "content": "告白のタイミングを...",
      "category": "love",
      "sympathy_count": 42,
      "reply_count": 5,
      "is_resolved": false,
      "created_at": "2024-01-20T10:00:00Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 10,
    "total_count": 100
  }
}
```

#### POST /api/v1/posts
```json
// Request
{
  "content": "中学生の時に...",
  "category": "school"
}

// Response
{
  "post": {
    "id": 2,
    "nickname": "迷える子羊#456",
    "content": "中学生の時に...",
    "category": "school",
    "sympathy_count": 0,
    "reply_count": 0,
    "created_at": "2024-01-20T11:00:00Z"
  },
  "points_earned": 10
}
```

### 4.3 供養API

#### POST /api/v1/posts/:id/sympathies
```json
// Response
{
  "sympathy_count": 43,
  "points_earned": 1
}
```

### 4.4 リライト案API

#### POST /api/v1/posts/:id/replies
```json
// Request
{
  "content": "その状況なら、こうすれば良かったかも..."
}

// Response
{
  "reply": {
    "id": 1,
    "content": "その状況なら、こうすれば良かったかも...",
    "created_at": "2024-01-20T12:00:00Z"
  },
  "points_earned": 5
}
```

## 5. セキュリティ設計

### 5.1 認証・認可

- **JWT認証**
  - アクセストークン有効期限: 24時間
  - リフレッシュトークン有効期限: 30日
  - トークンローテーション実装

- **APIレート制限**
  - 認証API: 5回/分
  - 投稿API: 10回/分
  - その他API: 100回/分

### 5.2 データ保護

- **匿名性の確保**
  - ユーザーIDとニックネームの紐付けを暗号化
  - IPアドレスは保存しない
  - 投稿者情報はAPIレスポンスに含めない

- **コンテンツフィルタリング**
  - NGワードリストによる自動検出
  - 個人情報パターンマッチング
  - 不適切画像検出（将来実装）

## 6. エラーハンドリング

### 6.1 エラー分類

| エラーコード | 説明 | 対処方法 |
|---|---|---|
| 400 | Bad Request | 入力値検証エラーを表示 |
| 401 | Unauthorized | ログイン画面へ遷移 |
| 403 | Forbidden | アクセス権限エラーを表示 |
| 404 | Not Found | コンテンツが見つからない旨を表示 |
| 422 | Unprocessable Entity | バリデーションエラーを表示 |
| 429 | Too Many Requests | レート制限エラーを表示 |
| 500 | Internal Server Error | システムエラーメッセージを表示 |

### 6.2 エラーレスポンス形式

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "入力内容に誤りがあります",
    "details": {
      "content": ["1000文字以内で入力してください"]
    }
  }
}
```

## 7. テスト戦略

### 7.1 単体テスト

- **Backend**
  - カバレッジ目標: 80%以上
  - テストフレームワーク: RSpec
  - モック: FactoryBot, WebMock

- **iOS**
  - カバレッジ目標: 70%以上
  - テストフレームワーク: XCTest
  - UI Testing: XCUITest

### 7.2 統合テスト

- **APIテスト**
  - Postman/Newman による自動テスト
  - シナリオベースのE2Eテスト

- **負荷テスト**
  - Apache JMeter
  - 同時接続数: 1000ユーザー

## 8. パフォーマンス最適化

### 8.1 想定される負荷

- 同時アクティブユーザー: 1000人
- ピーク時リクエスト: 1000 req/秒
- データ量: 投稿10万件/月

### 8.2 最適化方針

- **Backend**
  - N+1クエリの回避（includes使用）
  - インデックスの適切な設定
  - ページネーション実装
  - キャッシュ活用（人気投稿など）

- **iOS**
  - 画像の遅延読み込み
  - APIレスポンスのキャッシュ
  - 無限スクロール実装
  - オフライン対応

## 9. デプロイメント

### 9.1 開発環境構成

```yaml
# docker-compose.yml
version: '3.8'
services:
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      - RAILS_ENV=development
      - DATABASE_URL=mysql2://root:password@db:3306/kuyou_dev
    depends_on:
      - db

  db:
    image: mysql:8.0
    environment:
      - MYSQL_ROOT_PASSWORD=password
      - MYSQL_DATABASE=kuyou_dev
    volumes:
      - mysql_data:/var/lib/mysql

  swagger:
    image: swaggerapi/swagger-ui
    ports:
      - "8080:8080"
    environment:
      - SWAGGER_JSON=/api/swagger.yaml
    volumes:
      - ./swagger:/api
```

### 9.2 環境変数管理

```ruby
# config/application.rb
# 必須環境変数
# - DATABASE_URL
# - SECRET_KEY_BASE
# - JWT_SECRET_KEY
# - RAILS_MASTER_KEY
```

## 10. 実装上の注意事項

- **匿名性の保証**: ユーザー特定につながる情報は一切保存・表示しない
- **不適切コンテンツ**: MVP段階では事後通報制とし、NGワードフィルタのみ実装
- **徳ポイント**: トランザクション内で確実に付与し、不整合を防ぐ
- **成仏処理**: 論理削除とし、涅槃堂機能の実装に備える
- **エラーメッセージ**: ユーザーフレンドリーな日本語表記
- **アクセシビリティ**: VoiceOver対応、Dynamic Type対応
- **並行性**: 供養の重複防止、楽観的ロックの実装