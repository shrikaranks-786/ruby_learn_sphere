# app/controllers/admins/otp_controller.rb
class Admin::OtpController < DeviseController
  protect_from_forgery except: :verify_otp
  
  def generate_otp
    admin = Admin.find_by(email: params[:email])
    if admin
      otp = admin.generate_otp
      OtpMailer.send_admin_otp(admin, otp).deliver_now
      render json: { message: 'OTP has been sent to your email' }
    else
      render json: { error: 'Admin not found' }, status: :not_found
    end
  end

  def verify_otp
    admin = Admin.find_by(email: params[:email])
    if admin && admin.valid_otp?(params[:otp])
      sign_in(admin)
      render json: { 
        message: 'Successfully verified', 
        redirect_url: after_sign_in_path_for(admin)
      }
    else
      render json: { error: 'Invalid OTP' }, status: :unprocessable_entity
    end
  end
end