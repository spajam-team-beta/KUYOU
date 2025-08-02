module Api
  module V1
    class PostsController < Api::BaseController
      skip_before_action :authenticate_user!, only: [:index, :show]
      before_action :set_post, only: [:show, :update, :destroy]
      
      def index
        posts = Post.active_posts
                   .includes(:user)
                   .by_category(params[:category])
                   
        posts = case params[:sort]
                when 'popular'
                  posts.popular
                else
                  posts.recent
                end
        
        posts = posts.page(params[:page]).per(params[:per_page] || 10)
        
        render json: {
          posts: posts.map { |post| PostSerializer.new(post, { params: { current_user: current_user } }).serializable_hash[:data][:attributes] },
          meta: pagination_meta(posts)
        }
      end
      
      def show
        render json: {
          post: PostSerializer.new(@post, { params: { current_user: current_user } }).serializable_hash[:data][:attributes]
        }
      end
      
      def create
        result = Posts::CreateService.call(
          user: current_user,
          content: post_params[:content],
          category: post_params[:category]
        )
        
        if result[:success]
          render json: {
            post: PostSerializer.new(result[:post], { params: { current_user: current_user } }).serializable_hash[:data][:attributes],
            points_earned: result[:points_earned]
          }, status: :created
        else
          render json: { error: result[:error] }, status: :unprocessable_entity
        end
      end
      
      def update
        authorize_user!
        
        if @post.update(post_params)
          render json: {
            post: PostSerializer.new(@post, { params: { current_user: current_user } }).serializable_hash[:data][:attributes]
          }
        else
          render json: { error: @post.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      def destroy
        authorize_user!
        
        @post.destroy
        render json: { message: '投稿を削除しました' }
      end
      
      private
      
      def set_post
        @post = Post.find(params[:id])
      end
      
      def post_params
        params.require(:post).permit(:content, :category)
      end
      
      def authorize_user!
        unless @post.user == current_user
          render json: { error: '権限がありません' }, status: :forbidden
        end
      end
    end
  end
end