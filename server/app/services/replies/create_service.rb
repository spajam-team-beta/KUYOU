module Replies
  class CreateService
    def self.call(post:, user:, content:)
      new(post: post, user: user, content: content).call
    end

    def initialize(post:, user:, content:)
      @post = post
      @user = user
      @content = content
    end

    def call
      return { success: false, error: '成仏済みの投稿にはリライト案を投稿できません' } if @post.resolved?
      
      ActiveRecord::Base.transaction do
        validate_content!
        reply = create_reply
        points_earned = calculate_points
        
        { success: true, reply: reply, points_earned: points_earned }
      end
    rescue StandardError => e
      { success: false, error: e.message }
    end

    private

    def validate_content!
      result = ContentFilters::ValidateService.call(content: @content)
      raise StandardError, result[:error] unless result[:success]
    end

    def create_reply
      @post.replies.create!(
        user: @user,
        content: @content
      )
    end

    def calculate_points
      Points::CalculateService.call(
        user: @user,
        action: :reply_created
      )[:points_added]
    end
  end
end