module Posts
  class CreateService
    def self.call(user:, content:, category:)
      new(user: user, content: content, category: category).call
    end

    def initialize(user:, content:, category:)
      @user = user
      @content = content
      @category = category
    end

    def call
      ActiveRecord::Base.transaction do
        validate_content!
        post = create_post_with_nickname
        points_earned = calculate_points
        
        { success: true, post: post, points_earned: points_earned }
      end
    rescue StandardError => e
      { success: false, error: e.message }
    end

    private

    def validate_content!
      result = ContentFilters::ValidateService.call(content: @content)
      raise StandardError, result[:error] unless result[:success]
    end

    def create_post_with_nickname
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
      )[:points_added]
    end
  end
end