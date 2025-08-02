module Api
  module V1
    class TestController < Api::BaseController
      skip_before_action :authenticate_user!
      
      def send_test_email
        email = params[:email] || 'test@example.com'
        TestMailer.welcome(email).deliver_now
        render json: { message: 'テストメールを送信しました', email: email }
      end
    end
  end
end