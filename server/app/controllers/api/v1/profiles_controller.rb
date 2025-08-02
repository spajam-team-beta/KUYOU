module Api
  module V1
    class ProfilesController < Api::BaseController
      def show
        render json: {
          profile: {
            user: UserSerializer.new(current_user).serializable_hash[:data][:attributes],
            stats: user_stats
          }
        }
      end
      
      def update
        if current_user.update(profile_params)
          render json: {
            user: UserSerializer.new(current_user).serializable_hash[:data][:attributes]
          }
        else
          render json: { error: current_user.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      private
      
      def profile_params
        params.require(:user).permit(:email)
      end
      
      def user_stats
        {
          total_posts: current_user.posts.count,
          active_posts: current_user.posts.active_posts.count,
          resolved_posts: current_user.posts.resolved_posts.count,
          total_replies: current_user.replies.count,
          best_replies: current_user.replies.best_replies.count,
          total_sympathies_given: current_user.sympathies.count,
          total_sympathies_received: current_user.posts.sum(:sympathy_count)
        }
      end
    end
  end
end