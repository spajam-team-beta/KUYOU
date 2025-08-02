module Replies
  class SelectBestService
    def self.call(post:, reply:)
      new(post: post, reply: reply).call
    end

    private

    def initialize(post:, reply:)
      @post = post
      @reply = reply
    end

    def call
      return { success: false, error: '既に成仏済みです' } if @post.resolved?
      return { success: false, error: 'このリライト案は他の投稿のものです' } if @reply.post != @post
      
      ActiveRecord::Base.transaction do
        resolve_post!
        post_points = give_post_owner_points
        reply_points = give_reply_owner_points
        
        {
          success: true,
          post_points: post_points,
          reply_points: reply_points
        }
      end
    rescue StandardError => e
      { success: false, error: e.message }
    end

    def resolve_post!
      @post.resolve_with_best_reply!(@reply)
    end

    def give_post_owner_points
      Points::CalculateService.call(
        user: @post.user,
        action: :best_answer_selected
      )[:points_added]
    end

    def give_reply_owner_points
      Points::CalculateService.call(
        user: @reply.user,
        action: :best_answer_received
      )[:points_added]
    end
  end
end