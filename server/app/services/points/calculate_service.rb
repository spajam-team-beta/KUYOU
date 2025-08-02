module Points
  class CalculateService
    POINT_RULES = {
      post_created: 10,
      sympathy_given: 0,
      sympathy_received: 1,
      reply_created: 5,
      best_answer_selected: 50,  # 投稿者
      best_answer_received: 30   # 回答者
    }.freeze
    
    def self.call(user:, action:, amount: nil)
      new(user: user, action: action, amount: amount).call
    end
    
    private
    
    def initialize(user:, action:, amount: nil)
      @user = user
      @action = action.to_sym
      @amount = amount
    end
    
    def call
      points_to_add = @amount || POINT_RULES[@action] || 0
      
      if points_to_add > 0
        @user.add_points(points_to_add)
        { success: true, points_added: points_to_add, total_points: @user.total_points }
      else
        { success: true, points_added: 0, total_points: @user.total_points }
      end
    rescue StandardError => e
      { success: false, error: e.message }
    end
  end
end