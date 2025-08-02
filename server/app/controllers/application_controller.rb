class ApplicationController < ActionController::API
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  protected
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email])
    devise_parameter_sanitizer.permit(:account_update, keys: [:email])
  end
  
  def authenticate_request!
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    
    begin
      decoded = JWT.decode(header, Rails.application.credentials.secret_key_base || 'default_secret')
      @current_user = User.find(decoded[0]['user_id'])
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      render json: { error: '認証が必要です' }, status: :unauthorized
    end
  end
  
  def current_user
    @current_user
  end
end
