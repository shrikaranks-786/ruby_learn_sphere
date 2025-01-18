# app/mailers/otp_mailer.rb
class OtpMailer < ApplicationMailer
  def send_otp(user, otp)
    @user = user
    @otp = otp
    mail(
      to: @user.email,
      subject: "Your Login OTP"
    )
  end
end