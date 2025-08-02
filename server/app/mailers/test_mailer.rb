class TestMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.test_mailer.welcome.subject
  #
  def welcome(email)
    @greeting = "KUYOUアプリへようこそ！"

    mail(
      to: email,
      subject: 'KUYOUへようこそ - letter_openerテスト'
    )
  end
end
