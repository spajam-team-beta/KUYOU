module Api
  module V1
    module Auth
      class SessionsController < Devise::SessionsController
        respond_to :json
        
        skip_before_action :verify_authenticity_token, raise: false
        
        private
        
        def respond_with(resource, _opts = {})
          render json: {
            user: UserSerializer.new(resource).serializable_hash,
            token: request.env['warden-jwt_auth.token']
          }, status: :ok
        end
        
        def respond_to_on_destroy
          if current_user
            render json: { message: 'ログアウトしました' }, status: :ok
          else
            render json: { error: 'ログアウトに失敗しました' }, status: :unauthorized
          end
        end
      end
    end
  end
end