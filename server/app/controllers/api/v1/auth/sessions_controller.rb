module Api
  module V1
    module Auth
      class SessionsController < Devise::SessionsController
        respond_to :json
        
        def create
          Rails.logger.info "Raw params: #{params.inspect}"
          Rails.logger.info "User params: #{user_params.inspect}"
          
          # Extract email and password from nested user params
          if params[:user].present?
            request.params[:email] = params[:user][:email]
            request.params[:password] = params[:user][:password]
          end
          
          super
        end
        
        private
        
        def user_params
          params.require(:user).permit(:email, :password)
        end
        
        def respond_with(resource, _opts = {})
          Rails.logger.info "SessionsController#respond_with called"
          Rails.logger.info "Resource: #{resource.inspect}"
          Rails.logger.info "Resource persisted: #{resource.persisted?}"
          Rails.logger.info "Resource errors: #{resource.errors.full_messages}"
          
          if resource.persisted?
            token = request.env['warden-jwt_auth.token']
            Rails.logger.info "JWT Token: #{token}"
            
            render json: {
              user: UserSerializer.new(resource).serializable_hash,
              token: token
            }, status: :ok
          else
            render json: {
              error: 'メールアドレスまたはパスワードが正しくありません'
            }, status: :unauthorized
          end
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