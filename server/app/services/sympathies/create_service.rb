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
      return { success: false, error: '既に供養済みです' } if already_sympathized?
      
      ActiveRecord::Base.transaction do
        create_sympathy
        give_points
        
        {
          success: true,
          sympathy_count: @post.reload.sympathy_count,
          points_earned: 1
        }
      end
    rescue StandardError => e
      { success: false, error: e.message }
    end

    def already_sympathized?
      @post.sympathies.exists?(user: @user)
    end

    def create_sympathy
      @post.sympathies.create!(user: @user)
    end

    def give_points
      # 供養された側（投稿者）にポイント付与
      Points::CalculateService.call(
        user: @post.user,
        action: :sympathy_received
      )
    end
  end
end