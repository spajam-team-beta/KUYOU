module Api
  module V1
    class AuthController < ApplicationController
      # ユーザー登録
      def register
        user = User.new(user_params)
        
        if user.save
          token = generate_jwt_token(user)
          render json: {
            user: UserSerializer.new(user).serializable_hash,
            token: token
          }, status: :created
        else
          render json: {
            error: user.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
      
      # ログイン
      def login
        user = User.find_by(email: params.dig(:user, :email))
        
        if user&.valid_password?(params.dig(:user, :password))
          token = generate_jwt_token(user)
          render json: {
            user: UserSerializer.new(user).serializable_hash,
            token: token
          }, status: :ok
        else
          render json: {
            error: 'メールアドレスまたはパスワードが正しくありません'
          }, status: :unauthorized
        end
      end
      
      # ログアウト（JWTではクライアント側でトークンを削除）
      def logout
        render json: { message: 'ログアウトしました' }, status: :ok
      end
      
      private
      
      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation)
      end
      
      def generate_jwt_token(user)
        payload = {
          user_id: user.id,
          email: user.email,
          exp: 24.hours.from_now.to_i
        }
        
        JWT.encode(payload, Rails.application.credentials.secret_key_base || 'default_secret')
      end
    end
  end
end