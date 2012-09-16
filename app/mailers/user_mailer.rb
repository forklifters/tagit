class UserMailer < ActionMailer::Base
  default from: "vdsabev@gmail.com"

  def password_reset(user)
    @user = user
    mail to: user.email, subject: t(:password_reset_subject)
  end
end
