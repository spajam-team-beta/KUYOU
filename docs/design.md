# 詳細設計書 - KUYOU（黒歴史供養プラットフォーム）

## 1. アーキテクチャ概要

### 1.1 システム構成図

```
┌─────────────────────────────────────────────────────────────┐
│                      KUYOU iOS App                          │
├─────────────────────────────────────────────────────────────┤
│                    Presentation Layer                        │
│  ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────┐  │
│  │ PostView   │ │TimelineView│ │DetailView  │ │Profile │  │
│  │(懺悔の間)  │ │(供養の広場) │ │(詳細画面)   │ │ View   │  │
│  └────────────┘ └────────────┘ └────────────┘ └────────┘  │
├─────────────────────────────────────────────────────────────┤
│                    ViewModel Layer                           │
│  ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────┐  │
│  │   PostVM   │ │TimelineVM  │ │ DetailVM   │ │Profile │  │
│  │            │ │            │ │            │ │   VM   │  │
│  └────────────┘ └────────────┘ └────────────┘ └────────┘  │
├─────────────────────────────────────────────────────────────┤
│                     Model Layer                              │
│  ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────┐  │
│  │BlackHistory│ │  Rewrite   │ │   User     │ │ Points │  │
│  │   Model    │ │   Model    │ │   Model    │ │ Model  │  │
│  └────────────┘ └────────────┘ └────────────┘ └────────┘  │
├─────────────────────────────────────────────────────────────┤
│                    Service Layer                             │
│  ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────┐  │
│  │  Storage   │ │   Audio    │ │ Animation  │ │Content │  │
│  │  Service   │ │  Service   │ │  Service   │ │ Filter │  │
│  └────────────┘ └────────────┘ └────────────┘ └────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 技術スタック

- **言語**: Swift 5.9+
- **UI フレームワーク**: SwiftUI
- **アーキテクチャ**: MVVM (Model-View-ViewModel)
- **データ永続化**: UserDefaults（初期版）、Core Data（将来）
- **音声再生**: AVFoundation
- **アニメーション**: SwiftUI Animation API
- **最小対応OS**: iOS 15.0+
- **開発環境**: Xcode 15.0+

## 2. コンポーネント設計

### 2.1 コンポーネント一覧

| コンポーネント名 | 責務 | 依存関係 |
|-----------------|------|----------|
| PostView | 黒歴史投稿画面の表示 | PostViewModel, CategoryPicker |
| TimelineView | 投稿一覧の表示 | TimelineViewModel, PostCardView |
| DetailView | 投稿詳細とリライト案表示 | DetailViewModel, RewriteView |
| PostCardView | 投稿カードのお札風表示 | BlackHistoryModel, AnimationService |
| RewriteView | リライト案投稿・表示 | RewriteModel |
| ProfileView | ユーザープロファイル表示 | ProfileViewModel |
| PostViewModel | 投稿ロジック管理 | StorageService, ContentFilter |
| TimelineViewModel | タイムラインデータ管理 | StorageService |
| DetailViewModel | 詳細画面ロジック管理 | StorageService, AudioService |
| StorageService | データ永続化 | UserDefaults/CoreData |
| AudioService | 効果音再生 | AVFoundation |
| AnimationService | アニメーション制御 | SwiftUI Animation |
| ContentFilter | 不適切コンテンツ検出 | - |

### 2.2 各コンポーネントの詳細

#### PostView（懺悔の間）

- **目的**: 黒歴史投稿画面の提供
- **主要機能**:
  ```swift
  struct PostView: View {
      @StateObject private var viewModel = PostViewModel()
      
      var body: some View {
          // 投稿フォーム
          // カテゴリ選択
          // 感情タグ選択
          // 投稿ボタン
      }
  }
  ```

#### TimelineView（供養の広場）

- **目的**: 投稿された黒歴史の一覧表示
- **主要機能**:
  ```swift
  struct TimelineView: View {
      @StateObject private var viewModel = TimelineViewModel()
      
      var body: some View {
          // フィルター機能
          // ソート機能
          // カード一覧表示
          // Pull to refresh
      }
  }
  ```

#### PostCardView（投稿カード）

- **目的**: お札/経典風デザインでの投稿表示
- **主要機能**:
  ```swift
  struct PostCardView: View {
      let post: BlackHistoryModel
      @State private var salvationCount: Int = 0
      
      var body: some View {
          // お札風デザイン
          // 供養ボタン（木魚アイコン）
          // タップアニメーション
      }
  }
  ```

## 3. データフロー

### 3.1 データフロー図

```
User Input → View → ViewModel → Service → Storage
                ↑                    ↓
                └──── Model Update ←─┘
```

### 3.2 データ変換

- **投稿フロー**:
  1. ユーザー入力（テキスト、カテゴリ、タグ）
  2. ContentFilter で内容チェック
  3. BlackHistoryModel オブジェクト生成
  4. StorageService で永続化
  5. 徳ポイント付与

- **供養フロー**:
  1. 供養ボタンタップ
  2. AudioService で効果音再生
  3. AnimationService でアニメーション
  4. 供養数インクリメント
  5. 徳ポイント計算・付与

## 4. データモデル

### 4.1 BlackHistoryModel

```swift
struct BlackHistoryModel: Identifiable, Codable {
    let id: UUID
    let content: String
    let category: Category
    let emotionTags: [EmotionTag]
    let createdAt: Date
    var salvationCount: Int
    var isResolved: Bool
    var bestAnswerId: UUID?
}
```

### 4.2 RewriteModel

```swift
struct RewriteModel: Identifiable, Codable {
    let id: UUID
    let blackHistoryId: UUID
    let content: String
    let route: RewriteRoute // 爆笑/感動/真理
    let createdAt: Date
    var likeCount: Int
}
```

### 4.3 UserModel

```swift
struct UserModel: Codable {
    let id: UUID
    var totalPoints: Int
    var postedHistories: [UUID]
    var achievements: [Achievement]
}
```

## 5. エラーハンドリング

### 5.1 エラー分類

- **投稿エラー**: 文字数制限、不適切コンテンツ検出
  - 対処: アラート表示、修正を促す
- **ストレージエラー**: 保存失敗
  - 対処: リトライ、オフラインキャッシュ
- **音声再生エラー**: ファイル読み込み失敗
  - 対処: サイレントフェイル、視覚的フィードバックで代替

### 5.2 エラー通知

```swift
enum KuyouError: LocalizedError {
    case invalidContent(String)
    case storageFailed
    case audioPlaybackFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidContent(let reason):
            return "投稿できません: \(reason)"
        case .storageFailed:
            return "保存に失敗しました"
        case .audioPlaybackFailed:
            return nil // サイレントフェイル
        }
    }
}
```

## 6. セキュリティ設計

### 6.1 匿名性の保証

- デバイスIDやIPアドレスの非保存
- 投稿とユーザーの非紐付け
- ランダムUUID使用

### 6.2 コンテンツフィルタリング

```swift
class ContentFilter {
    private let bannedWords: Set<String>
    
    func validate(_ content: String) -> Result<Void, KuyouError> {
        // NGワードチェック
        // 最小/最大文字数チェック
        // スパム検出
    }
}
```

## 7. テスト戦略

### 7.1 単体テスト

- **カバレッジ目標**: 60%以上
- **テスト対象**: ViewModel、Model、Service層
- **フレームワーク**: XCTest

### 7.2 UIテスト

- 主要フローのE2Eテスト
- 投稿→表示→供養→リライト→成仏の一連フロー

## 8. パフォーマンス最適化

### 8.1 想定される負荷

- タイムライン: 最大100件表示
- スクロール: 60fps維持
- 画像: お札デザインの最適化

### 8.2 最適化方針

- LazyVStack使用によるリスト最適化
- 画像キャッシュ
- 非同期データ読み込み
- アニメーションの軽量化

## 9. UI/UX設計方針

### 9.1 デザインテーマ

- 和風・寺院モチーフ
- 落ち着いた色調（紫、金、黒）
- お札・経典風のカードデザイン

### 9.2 アニメーション

- 供養時: 光が広がるエフェクト
- 成仏時: カードが天に昇るアニメーション
- 木魚タップ: バウンスアニメーション

## 10. 実装上の注意事項

- **ハッカソン対応**: MVPに集中、過度な機能追加を避ける
- **SwiftUI制約**: iOS 15.0対応のAPIのみ使用
- **効果音**: 著作権フリーの音源使用
- **テスト**: 基本フローの動作確認を優先
- **コード品質**: 可読性重視、過度な抽象化を避ける