module Api
  module V1
    class UsersController < Api::BaseController
      def show
        user = User.find(params[:id])
        
        render json: {
          user: UserSerializer.new(user).serializable_hash[:data][:attributes]
        }
      end
      
      def ranking
        users = User.order(total_points: :desc)
                   .limit(params[:limit] || 100)
        
        render json: {
          ranking: users.map.with_index do |user, index|
            {
              rank: index + 1,
              id: user.id,
              nickname: user.display_nickname,
              email: mask_email(user.email),
              total_points: user.total_points
            }
          end
        }
      end
      
      def points_history
        user = User.find(params[:id])
        
        # 簡易的な実装。本来はポイント履歴テーブルが必要
        render json: {
          message: 'ポイント履歴機能は後日実装予定です',
          current_points: user.total_points
        }
      end
      
      private
      
      def mask_email(email)
        parts = email.split('@')
        username = parts[0]
        domain = parts[1]
        
        masked_username = username[0..1] + '*' * (username.length - 2)
        "#{masked_username}@#{domain}"
      end
    end
  end
end