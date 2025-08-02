module Api
  module V1
    class SympathiesController < Api::BaseController
      before_action :set_post
      
      def create
        result = Sympathies::CreateService.call(
          post: @post,
          user: current_user
        )
        
        if result[:success]
          render json: {
            sympathy_count: result[:sympathy_count],
            points_earned: result[:points_earned]
          }, status: :created
        else
          render json: { error: result[:error] }, status: :unprocessable_entity
        end
      end
      
      def destroy
        sympathy = @post.sympathies.find_by(user: current_user)
        
        if sympathy&.destroy
          render json: {
            sympathy_count: @post.reload.sympathy_count,
            message: '供養を取り消しました'
          }
        else
          render json: { error: '供養が見つかりません' }, status: :not_found
        end
      end
      
      private
      
      def set_post
        @post = Post.find(params[:post_id])
      end
    end
  end
end