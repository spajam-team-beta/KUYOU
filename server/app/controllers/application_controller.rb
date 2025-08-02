class ApplicationController < ActionController::API
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  include Devise::Controllers::Helpers
  
  protected
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email])
    devise_parameter_sanitizer.permit(:account_update, keys: [:email])
  end
  
  def authenticate_user!
    begin
      # Warden経由でユーザー認証を行う
      warden = request.env['warden']
      @current_user = warden.authenticate(:jwt)
      
      unless @current_user
        render json: { error: 'トークンが必要です' }, status: :unauthorized
        return
      end
      
      Rails.logger.info "Current user authenticated: #{@current_user.email}"
      
    rescue => e
      Rails.logger.error "Authentication error: #{e.message}"
      render json: { error: '認証に失敗しました' }, status: :unauthorized
    end
  end
  
  def current_user
    @current_user
  end
end
