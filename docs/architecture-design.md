# アーキテクチャ設計書 - KUYOU

## 1. アーキテクチャ概要

### 1.1 採用アーキテクチャ
- **MVVM (Model-View-ViewModel)** パターン
- **Feature-based** ディレクトリ構造
- **SwiftUI** のデータフロー設計に準拠

### 1.2 設計方針
- 機能ごとにモジュール化（Feature-based）
- SwiftUIの特性を活かしたシンプルな実装
- ハッカソン期間での高速開発を重視
- 可読性と保守性のバランス

## 2. ディレクトリ構成

```
KUYOU/
├── App/
│   ├── KUYOUApp.swift              # アプリエントリポイント
│   └── ContentView.swift           # ルートビュー
│
├── Features/
│   ├── Confession/                 # 懺悔の間機能
│   │   ├── Views/
│   │   │   ├── ConfessionView.swift
│   │   │   └── ConfessionFormView.swift
│   │   ├── ViewModels/
│   │   │   └── ConfessionViewModel.swift
│   │   └── Models/
│   │       └── ConfessionDraft.swift
│   │
│   ├── Timeline/                   # 供養の広場機能
│   │   ├── Views/
│   │   │   ├── TimelineView.swift
│   │   │   ├── BlackHistoryCard.swift
│   │   │   └── KuyoButton.swift
│   │   ├── ViewModels/
│   │   │   └── TimelineViewModel.swift
│   │   └── Models/
│   │       └── TimelineFilter.swift
│   │
│   ├── Wisdom/                     # 智慧の泉機能
│   │   ├── Views/
│   │   │   ├── WisdomView.swift
│   │   │   ├── RewriteProposalView.swift
│   │   │   └── JobutsuEffectView.swift
│   │   ├── ViewModels/
│   │   │   └── WisdomViewModel.swift
│   │   └── Models/
│   │       └── RewriteProposal.swift
│   │
│   └── Profile/                    # プロフィール機能
│       ├── Views/
│       │   └── ProfileView.swift
│       ├── ViewModels/
│       │   └── ProfileViewModel.swift
│       └── Models/
│           └── UserProfile.swift
│
├── Shared/
│   ├── Models/                     # 共通モデル
│   │   ├── BlackHistory.swift
│   │   ├── Category.swift
│   │   ├── EmotionTag.swift
│   │   └── MeritPoint.swift
│   │
│   ├── Views/                      # 共通ビューコンポーネント
│   │   ├── Components/
│   │   │   ├── TagChip.swift
│   │   │   ├── CategoryPicker.swift
│   │   │   └── LoadingView.swift
│   │   └── Modifiers/
│   │       ├── CardStyle.swift
│   │       └── ButtonStyles.swift
│   │
│   ├── Services/                   # 共通サービス
│   │   ├── DataStore.swift         # データ永続化
│   │   ├── SoundPlayer.swift       # 効果音再生
│   │   └── HapticManager.swift    # 触覚フィードバック
│   │
│   └── Utils/                      # ユーティリティ
│       ├── Extensions/
│       │   ├── View+Extensions.swift
│       │   └── Date+Extensions.swift
│       └── Constants.swift         # アプリ定数
│
├── Resources/
│   ├── Sounds/                     # 効果音ファイル
│   │   └── pokupoku.mp3
│   └── Localizable.strings         # ローカライズ
│
└── Supporting Files/
    ├── Assets.xcassets/
    └── Info.plist
```

## 3. データフロー設計

### 3.1 MVVM パターン
```
View (SwiftUI) ← @Published → ViewModel ← → Model/Service
     ↓ User Action              ↓ Business Logic
     → ViewModel.method()       → DataStore/API
```

### 3.2 状態管理
- **@StateObject**: 各画面でViewModelを保持
- **@Published**: ViewModelの状態変更をViewに通知
- **@AppStorage**: ユーザー設定の永続化
- **@EnvironmentObject**: アプリ全体の共有状態（DataStore）

## 4. 主要コンポーネント設計

### 4.1 Feature: Confession（懺悔の間）

#### ConfessionViewModel
```swift
class ConfessionViewModel: ObservableObject {
    @Published var content: String = ""
    @Published var selectedCategory: Category?
    @Published var selectedTags: Set<EmotionTag> = []
    @Published var isPosting: Bool = false
    
    func postBlackHistory() async
    func validateInput() -> Bool
}
```

#### ConfessionView
- テキスト入力エリア
- カテゴリ選択
- 感情タグ選択
- 投稿ボタン

### 4.2 Feature: Timeline（供養の広場）

#### TimelineViewModel
```swift
class TimelineViewModel: ObservableObject {
    @Published var blackHistories: [BlackHistory] = []
    @Published var filter: TimelineFilter = .all
    @Published var sortOrder: SortOrder = .newest
    
    func loadBlackHistories() async
    func performKuyo(for id: UUID) async
    func applyFilter(_ filter: TimelineFilter)
}
```

#### BlackHistoryCard
- お札/経典風デザイン
- カテゴリ表示
- 感情タグ表示
- 供養数表示

### 4.3 Feature: Wisdom（智慧の泉）

#### WisdomViewModel
```swift
class WisdomViewModel: ObservableObject {
    @Published var currentBlackHistory: BlackHistory?
    @Published var rewriteProposals: [RewriteProposal] = []
    @Published var newProposal: String = ""
    @Published var selectedRoute: RewriteRoute = .comedy
    
    func postRewriteProposal() async
    func selectBestAnswer(_ proposalId: UUID) async
}
```

### 4.4 Shared Services

#### DataStore
```swift
@MainActor
class DataStore: ObservableObject {
    @Published var blackHistories: [BlackHistory] = []
    @Published var currentUser: UserProfile?
    
    func save(_ blackHistory: BlackHistory)
    func loadAll() -> [BlackHistory]
    func updateKuyoCount(for id: UUID)
    func markAsJobutsu(_ id: UUID)
}
```

#### SoundPlayer
```swift
class SoundPlayer {
    static let shared = SoundPlayer()
    
    func playKuyoSound()
    func playJobutsuSound()
}
```

## 5. モデル設計

### 5.1 BlackHistory
```swift
struct BlackHistory: Identifiable, Codable {
    let id: UUID
    let content: String
    let category: Category
    let emotionTags: [EmotionTag]
    var kuyoCount: Int
    var rewriteProposals: [RewriteProposal]
    var bestAnswerId: UUID?
    var isJobutsu: Bool
    let createdAt: Date
}
```

### 5.2 Category（列挙型）
```swift
enum Category: String, CaseIterable, Codable {
    case love = "恋愛"
    case chuunibyou = "中二病"
    case sns = "SNS"
    case school = "学校生活"
    case family = "家族"
}
```

### 5.3 EmotionTag（列挙型）
```swift
enum EmotionTag: String, CaseIterable, Codable {
    case maxEmbarrassment = "赤面レベルMAX"
    case turnBackTime = "時を戻したい"
    case ratherProud = "むしろ誇り"
    case helpMe = "誰か助けて"
}
```

## 6. UI/UX 設計方針

### 6.1 デザインシステム
- **カラーパレット**: 和風の落ち着いた色調
  - Primary: 深紅（#8B0000）
  - Secondary: 金色（#FFD700）
  - Background: 和紙色（#F5F5DC）

### 6.2 アニメーション
- 供養時: 木魚タップで波紋エフェクト
- 成仏時: 光のパーティクルエフェクト
- カード表示: フェードイン

### 6.3 サウンド
- 供養音: 「ポクポク」
- 成仏音: 「チーン」+ 光の音

## 7. 実装優先順位

### Phase 1 (Day 1 AM)
1. プロジェクト構造のセットアップ
2. 基本モデルの実装
3. TabViewによる画面切り替え
4. 懺悔投稿機能

### Phase 1 (Day 1 PM)
1. タイムライン表示
2. 供養機能（効果音付き）
3. データ永続化（UserDefaults）

### Phase 2 (Day 2 AM)
1. リライト案投稿機能
2. ベストアンサー選定
3. 成仏エフェクト

### Phase 2 (Day 2 PM)
1. UI/UXブラッシュアップ
2. アニメーション追加
3. バグ修正とテスト

## 8. 技術スタック

### 8.1 フレームワーク
- SwiftUI
- Combine（必要に応じて）
- AVFoundation（効果音）

### 8.2 データ永続化
- UserDefaults（初期実装）
- JSONエンコード/デコード

### 8.3 非同期処理
- async/await
- Task/MainActor

## 9. 開発ガイドライン

### 9.1 命名規則
- View: ~View
- ViewModel: ~ViewModel
- Model: 単数形の名詞
- Service: ~Service, ~Manager

### 9.2 コーディング規約
- SwiftLintの基本ルールに準拠
- 1ファイル1型を基本とする
- プロトコル指向を心がける

### 9.3 Git運用
- Feature Branch戦略
- コミットメッセージは日本語可
- PR前にビルドエラーがないことを確認