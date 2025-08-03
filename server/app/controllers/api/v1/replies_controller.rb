module Api
  module V1
    class RepliesController < Api::BaseController
      before_action :set_post
      before_action :set_reply, only: [:select_best]
      
      
      def index
        replies = @post.replies.includes(:user).recent
        
        render json: {
          replies: replies.map { |reply| ReplySerializer.new(reply, params: { current_user: current_user }).serializable_hash[:data][:attributes] }
        }
      end
      
      def create
        result = Replies::CreateService.call(
          post: @post,
          user: current_user,
          content: reply_params[:content]
        )
        
        if result[:success]
          render json: {
            reply: ReplySerializer.new(result[:reply], params: { current_user: current_user }).serializable_hash[:data][:attributes],
            points_earned: result[:points_earned]
          }, status: :created
        else
          render json: { error: result[:error] }, status: :unprocessable_entity
        end
      end
      
      def select_best
        authorize_post_owner!
        
        result = Replies::SelectBestService.call(
          post: @post,
          reply: @reply
        )
        
        if result[:success]
          render json: {
            message: 'ベストアンサーを選択しました',
            post_points: result[:post_points],
            reply_points: result[:reply_points]
          }
        else
          render json: { error: result[:error] }, status: :unprocessable_entity
        end
      end
      
      private
      
      def set_post
        @post = Post.find(params[:post_id])
      end
      
      def set_reply
        @reply = @post.replies.find(params[:id])
      end
      
      def reply_params
        params.require(:reply).permit(:content)
      end
      
      def authorize_post_owner!
        unless @post.user == current_user
          render json: { error: '投稿者のみがベストアンサーを選択できます' }, status: :forbidden
        end
      end
    end
  end
end