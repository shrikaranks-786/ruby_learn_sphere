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

  def send_admin_otp(admin, otp)
    @admin = admin
    @otp = otp
    mail(
      to: @admin.email,
      subject: "Admin Login OTP"
    )
  end
end