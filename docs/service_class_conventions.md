# Railsサービスクラス規約

## 基本ルール

1. **Namespace必須**
   - すべてのサービスクラスは何らかのnamespaceに所属する
   - app/services直下にクラスを置くことは禁止

2. **インターフェース**
   - `call`というpublicクラスメソッドを唯一のエントリーポイントとする
   - privateメソッドは任意に配置可能

## ディレクトリ構造

```
app/services/
├── auth/
│   ├── register_service.rb
│   └── login_service.rb
├── posts/
│   ├── create_service.rb
│   └── resolve_service.rb
├── sympathies/
│   └── create_service.rb
├── replies/
│   ├── create_service.rb
│   └── select_best_service.rb
├── points/
│   └── calculate_service.rb
├── notifications/
│   └── create_service.rb
├── content_filters/
│   └── validate_service.rb
└── utils/
    ├── nickname_generator.rb
    └── ng_word_filter.rb
```

## 実装例

### 基本パターン

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
      ActiveRecord::Base.transaction do
        validate_content!
        post = create_post
        calculate_points
        
        { success: true, post: post }
      end
    rescue StandardError => e
      { success: false, error: e.message }
    end

    def validate_content!
      result = ContentFilters::ValidateService.call(content: @content)
      raise ValidationError, result[:error] unless result[:success]
    end

    def create_post
      Post.create!(
        user: @user,
        content: @content,
        category: @category,
        nickname: generate_nickname
      )
    end

    def generate_nickname
      Utils::NicknameGenerator.call
    end

    def calculate_points
      Points::CalculateService.call(
        user: @user,
        action: :post_created,
        amount: 10
      )
    end
  end
end
```

### 呼び出し例

```ruby
# コントローラーから
result = Posts::CreateService.call(
  user: current_user,
  content: params[:content],
  category: params[:category]
)

if result[:success]
  render json: result[:post], status: :created
else
  render json: { error: result[:error] }, status: :unprocessable_entity
end
```

## 命名規則

- Namespace: 複数形（Posts, Users, etc.）
- Service名: 動詞 + Service（CreateService, UpdateService, etc.）
- ファイル名: snake_case（create_service.rb）

## 返り値の規約

サービスクラスは以下の形式でハッシュを返すことを推奨：

```ruby
# 成功時
{ success: true, data: object, message: 'Success message' }

# 失敗時
{ success: false, error: 'Error message', error_code: 'ERROR_CODE' }
```