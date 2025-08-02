# UI/UXデザイン基本方針 - KUYOU

## 1. デザインコンセプト

### 1.1 ビジュアルアイデンティティ
- **テーマ**: 「和モダン × デジタル供養」
- **キーワード**: 温かみ、癒し、ユーモア、安心感
- **トーン**: カジュアルだが品のある和風デザイン

### 1.2 デザイン原則
1. **親しみやすさ**: 堅苦しくない、フレンドリーなUI
2. **直感的操作**: 初見でも使い方がわかる
3. **感情的な繋がり**: 共感と癒しを感じられるデザイン
4. **遊び心**: 供養や成仏の演出で楽しさを演出

## 2. カラーパレット

### 2.1 プライマリカラー
```swift
// メインカラー
let primary = Color(hex: "8B0000")        // 深紅（朱印色）
let secondary = Color(hex: "FFD700")      // 金色（仏具の金）
let accent = Color(hex: "4B0082")         // 紫（高貴な色）

// ベースカラー
let background = Color(hex: "F5F5DC")     // 和紙色
let surface = Color(hex: "FFFFFF")        // 白
let onSurface = Color(hex: "1A1A1A")      // 墨色
```

### 2.2 セマンティックカラー
```swift
// 状態色
let success = Color(hex: "228B22")        // 緑（成仏）
let warning = Color(hex: "FF8C00")        // 橙（注意）
let error = Color(hex: "DC143C")          // 赤（エラー）

// カテゴリ色
let loveColor = Color.pink
let chuunibyouColor = Color.purple
let snsColor = Color.blue
let schoolColor = Color.green
let familyColor = Color.orange
```

## 3. タイポグラフィ

### 3.1 フォント定義
```swift
// 日本語フォント
let titleFont = Font.custom("HiraginoSans-W6", size: 24)
let bodyFont = Font.custom("HiraginoSans-W3", size: 16)
let captionFont = Font.custom("HiraginoSans-W3", size: 12)

// 特殊用途
let zenFont = Font.custom("HiraMinProN-W6", size: 20)  // 禅的な表現用
```

### 3.2 テキストスタイル
- **見出し**: 太字、1.5倍行間
- **本文**: 標準、1.8倍行間（読みやすさ重視）
- **キャプション**: 小さめ、色を薄く

## 4. コンポーネントデザイン

### 4.1 黒歴史カード（お札デザイン）
```swift
struct BlackHistoryCardStyle {
    // 外観
    let cornerRadius: CGFloat = 0           // 直角（お札風）
    let borderWidth: CGFloat = 2
    let borderColor = Color.red.opacity(0.3)
    
    // 影
    let shadowColor = Color.black.opacity(0.1)
    let shadowRadius: CGFloat = 4
    let shadowOffset = CGSize(width: 0, height: 2)
    
    // 背景パターン
    let backgroundPattern = "和紙テクスチャ"
    let stampImage = "朱印風スタンプ"
}
```

### 4.2 供養ボタン（木魚）
```swift
struct KuyoButtonStyle {
    // サイズ
    let size: CGFloat = 60
    
    // アニメーション
    let tapScale: CGFloat = 0.9
    let rippleEffect = true
    let rippleColor = Color.gold.opacity(0.3)
    
    // サウンド
    let soundFile = "pokupoku.mp3"
}
```

### 4.3 成仏エフェクト
- 金色の光が広がる
- パーティクルエフェクト（蓮の花びら）
- フェードアウトアニメーション
- 「チーン」という鐘の音

## 5. レイアウト原則

### 5.1 スペーシング
```swift
enum Spacing {
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let m: CGFloat = 16
    static let l: CGFloat = 24
    static let xl: CGFloat = 32
}
```

### 5.2 グリッドシステム
- 8ptグリッドを基本とする
- カード間隔: 16pt
- 画面端マージン: 16pt

## 6. インタラクションデザイン

### 6.1 アニメーション
```swift
// 標準アニメーション時間
let quickAnimation = 0.2    // ボタンタップ
let normalAnimation = 0.3   // 画面遷移
let slowAnimation = 0.5     // 演出効果

// イージング
let standardEasing = Animation.easeInOut
let bounceEasing = Animation.spring()
```

### 6.2 ジェスチャー
- **タップ**: 主要なアクション
- **長押し**: 詳細表示、オプション表示
- **スワイプ**: カード送り、削除
- **ピンチ**: なし（シンプルさ重視）

### 6.3 フィードバック
- **触覚**: 供養時に軽い振動
- **音**: 効果音でアクションを強調
- **視覚**: アニメーションで状態変化を表現

## 7. 画面別デザインガイド

### 7.1 懺悔の間
- 和紙風の背景
- 筆文字風の入力UI
- カテゴリは家紋風アイコン
- 投稿ボタンは朱印風

### 7.2 供養の広場
- 巻物が広がるようなスクロール
- カードは少し傾けて重なり表現
- 供養数は小さな数珠アイコンで表示

### 7.3 智慧の泉
- 水面に映る月のような背景
- リライト案は短冊風デザイン
- ベストアンサーは金の短冊

### 7.4 マイページ
- 位牌風のプロフィールカード
- 徳ポイントは数珠で視覚化
- 実績は御朱印帳風

## 8. アイコンデザイン

### 8.1 カスタムアイコン
- 木魚アイコン（供養ボタン）
- 朱印スタンプ（投稿完了）
- 蓮の花（成仏）
- 数珠（徳ポイント）

### 8.2 SF Symbols 使用
```swift
// タブバーアイコン
"pencil.circle"      // 懺悔の間
"list.bullet"        // 供養の広場
"lightbulb"          // 智慧の泉
"person.circle"      // マイページ

// その他
"heart.fill"         // 恋愛カテゴリ
"sparkles"          // 中二病カテゴリ
```

## 9. アクセシビリティ

### 9.1 VoiceOver対応
- すべてのインタラクティブ要素にラベル設定
- 供養数、徳ポイントの読み上げ対応
- カスタムアクションの説明

### 9.2 Dynamic Type
- システムフォントサイズに追従
- 最小フォントサイズの保証
- レイアウトの自動調整

### 9.3 カラーコントラスト
- WCAG AA基準を満たす
- ダークモード対応
- 色覚多様性への配慮

## 10. レスポンシブデザイン

### 10.1 デバイス対応
```swift
// iPhone SE
let compactLayout = true
let reducedCardSize = true

// iPad
let multiColumnLayout = true
let expandedNavigation = true
```

### 10.2 画面回転
- Portrait優先
- Landscapeでは2カラムレイアウト

## 11. パフォーマンス考慮

### 11.1 画像最適化
- アイコン: PDF or SVG形式
- 背景: 低解像度 + ぼかし効果
- アニメーション: Core Animation使用

### 11.2 メモリ管理
- 画面外のビューは解放
- 画像キャッシュサイズ制限
- アニメーション終了後のリソース解放

## 12. 実装優先度

### 必須（MVP）
1. 基本的なカラーとフォント
2. カードレイアウト
3. 供養ボタンと効果音
4. シンプルな画面遷移

### 追加（時間があれば）
1. 詳細なアニメーション
2. カスタムアイコン
3. 背景パターン
4. 高度なエフェクト