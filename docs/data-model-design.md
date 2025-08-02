# データモデル設計書 - KUYOU

## 1. エンティティ設計

### 1.1 BlackHistory（黒歴史）
```swift
struct BlackHistory: Identifiable, Codable {
    let id: UUID                          // 一意識別子
    let content: String                   // 黒歴史の内容（最大500文字）
    let category: Category                // カテゴリ
    let emotionTags: [EmotionTag]        // 感情タグ（最大3つ）
    var kuyoCount: Int                    // 供養数
    var rewriteProposals: [RewriteProposal] // リライト案
    var bestAnswerId: UUID?               // ベストアンサーID
    var isJobutsu: Bool                   // 成仏フラグ
    let createdAt: Date                   // 投稿日時
    var jobutsuAt: Date?                  // 成仏日時
}
```

### 1.2 RewriteProposal（リライト案）
```swift
struct RewriteProposal: Identifiable, Codable {
    let id: UUID                          // 一意識別子
    let blackHistoryId: UUID              // 対象の黒歴史ID
    let content: String                   // リライト内容（最大300文字）
    let route: RewriteRoute               // リライトルート
    var likeCount: Int                    // いいね数
    let authorId: UUID                    // 投稿者ID（匿名）
    let createdAt: Date                   // 投稿日時
    var isBestAnswer: Bool                // ベストアンサーフラグ
}
```

### 1.3 User（ユーザー）
```swift
struct User: Codable {
    let id: UUID                          // ユーザーID（匿名）
    var totalMeritPoints: Int             // 累計徳ポイント
    var postedBlackHistories: [UUID]      // 投稿した黒歴史ID
    var kuyoHistory: [KuyoRecord]         // 供養履歴
    var rewriteHistory: [UUID]            // リライト案投稿履歴
    let createdAt: Date                   // アカウント作成日
}
```

### 1.4 KuyoRecord（供養記録）
```swift
struct KuyoRecord: Codable {
    let blackHistoryId: UUID              // 供養した黒歴史ID
    let kuyoAt: Date                      // 供養日時
}
```

## 2. 列挙型定義

### 2.1 Category（カテゴリ）
```swift
enum Category: String, CaseIterable, Codable {
    case love = "恋愛"
    case chuunibyou = "中二病"
    case sns = "SNS"
    case school = "学校生活"
    case family = "家族"
    case work = "仕事"
    case other = "その他"
    
    var icon: String {
        switch self {
        case .love: return "heart.fill"
        case .chuunibyou: return "sparkles"
        case .sns: return "bubble.left.fill"
        case .school: return "graduationcap.fill"
        case .family: return "house.fill"
        case .work: return "briefcase.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .love: return .pink
        case .chuunibyou: return .purple
        case .sns: return .blue
        case .school: return .green
        case .family: return .orange
        case .work: return .gray
        case .other: return .secondary
        }
    }
}
```

### 2.2 EmotionTag（感情タグ）
```swift
enum EmotionTag: String, CaseIterable, Codable {
    case maxEmbarrassment = "赤面レベルMAX"
    case turnBackTime = "時を戻したい"
    case ratherProud = "むしろ誇り"
    case helpMe = "誰か助けて"
    case whyDidIDo = "なぜやった"
    case youthful = "若気の至り"
    
    var emoji: String {
        switch self {
        case .maxEmbarrassment: return "😳"
        case .turnBackTime: return "⏰"
        case .ratherProud: return "😤"
        case .helpMe: return "🆘"
        case .whyDidIDo: return "🤦"
        case .youthful: return "🌸"
        }
    }
}
```

### 2.3 RewriteRoute（リライトルート）
```swift
enum RewriteRoute: String, CaseIterable, Codable {
    case comedy = "爆笑ルート"
    case touching = "感動ルート"
    case truth = "真理ルート"
    
    var description: String {
        switch self {
        case .comedy: return "ギャグに昇華させる"
        case .touching: return "実はいい話だったことにする"
        case .truth: return "ガチな人生の教訓を授ける"
        }
    }
    
    var icon: String {
        switch self {
        case .comedy: return "😂"
        case .touching: return "🥺"
        case .truth: return "🧘"
        }
    }
}
```

## 3. 値オブジェクト

### 3.1 MeritPoint（徳ポイント）
```swift
struct MeritPoint {
    enum Action: Int {
        case postBlackHistory = 10      // 黒歴史投稿
        case receiveKuyo = 1           // 供養される
        case postRewriteProposal = 5   // リライト案投稿
        case receiveBestAnswer = 50    // ベストアンサー選出
        case performKuyo = 1           // 供養する
    }
    
    static func calculate(for action: Action) -> Int {
        return action.rawValue
    }
}
```

### 3.2 TimelineFilter（タイムラインフィルター）
```swift
struct TimelineFilter {
    var categories: Set<Category> = Set(Category.allCases)
    var sortOrder: SortOrder = .newest
    var showOnlyJobutsu: Bool = false
    
    enum SortOrder: String, CaseIterable {
        case newest = "新着順"
        case mostKuyo = "供養数順"
        case random = "ランダム"
    }
}
```

## 4. データ永続化スキーマ

### 4.1 UserDefaults キー定義
```swift
enum UserDefaultsKey: String {
    case blackHistories = "kuyou.blackHistories"
    case userProfile = "kuyou.userProfile"
    case lastSyncDate = "kuyou.lastSyncDate"
    case appSettings = "kuyou.settings"
}
```

### 4.2 データ保存構造
```swift
// BlackHistoryの保存
{
    "blackHistories": [
        {
            "id": "UUID",
            "content": "String",
            "category": "String",
            "emotionTags": ["String"],
            "kuyoCount": Int,
            "rewriteProposals": [...],
            "bestAnswerId": "UUID?",
            "isJobutsu": Bool,
            "createdAt": TimeInterval,
            "jobutsuAt": TimeInterval?
        }
    ]
}
```

## 5. バリデーションルール

### 5.1 BlackHistory
- content: 10文字以上、500文字以下
- emotionTags: 1つ以上、3つ以下
- category: 必須選択

### 5.2 RewriteProposal
- content: 10文字以上、300文字以下
- route: 必須選択

### 5.3 制約事項
- 同一ユーザーは1つの黒歴史に1回のみ供養可能
- 成仏した黒歴史へは新規リライト案投稿不可
- ベストアンサーは投稿者のみ選択可能

## 6. モックデータ

### 6.1 サンプル黒歴史
```swift
extension BlackHistory {
    static let mockData = [
        BlackHistory(
            id: UUID(),
            content: "中学生の時、好きな子の前で『俺の右手に封印された力が...』とか言ってしまった。クラス全員に聞かれていた。",
            category: .chuunibyou,
            emotionTags: [.maxEmbarrassment, .whyDidIDo],
            kuyoCount: 42,
            rewriteProposals: [],
            bestAnswerId: nil,
            isJobutsu: false,
            createdAt: Date(),
            jobutsuAt: nil
        ),
        // ... more samples
    ]
}
```

## 7. データフロー

### 7.1 投稿フロー
```
1. ユーザー入力 → ConfessionViewModel
2. バリデーション
3. BlackHistory オブジェクト生成
4. DataStore.save()
5. UserDefaults 永続化
6. Timeline 更新通知
```

### 7.2 供養フロー
```
1. 供養ボタンタップ
2. kuyoCount インクリメント
3. UserProfile.kuyoHistory 追加
4. MeritPoint 計算・加算
5. DataStore 更新
6. UI リアルタイム反映
```

### 7.3 成仏フロー
```
1. ベストアンサー選択
2. RewriteProposal.isBestAnswer = true
3. BlackHistory.bestAnswerId 設定
4. BlackHistory.isJobutsu = true
5. BlackHistory.jobutsuAt = Date()
6. MeritPoint 付与
7. 成仏エフェクト表示
```

## 8. パフォーマンス考慮

### 8.1 インデックス
- BlackHistory.id
- BlackHistory.createdAt
- BlackHistory.category

### 8.2 キャッシュ戦略
- メモリキャッシュ: 最新100件
- ディスクキャッシュ: UserDefaults（全件）

### 8.3 データサイズ制限
- 1投稿あたり最大: 約2KB
- アプリ全体: 10MB まで（約5000投稿）