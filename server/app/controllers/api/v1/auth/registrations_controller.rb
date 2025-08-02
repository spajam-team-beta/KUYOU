module Api
  module V1
    module Auth
      class RegistrationsController < Devise::RegistrationsController
        respond_to :json
        
        skip_before_action :verify_authenticity_token, raise: false
        before_action :configure_sign_up_params, only: [:create]
        
        def create
          build_resource(sign_up_params)
          
          if resource.save
            token = Warden::JWTAuth::UserEncoder.new.call(resource, :user, nil).first
            render json: {
              user: UserSerializer.new(resource).serializable_hash,
              token: token
            }, status: :created
          else
            render json: {
              error: resource.errors.full_messages
            }, status: :unprocessable_entity
          end
        end
        
        private
        
        def configure_sign_up_params
          devise_parameter_sanitizer.permit(:sign_up, keys: [:email])
        end
        
        def sign_up_params
          params.require(:user).permit(:email, :password, :password_confirmation)
        end
      end
    end
  end
end