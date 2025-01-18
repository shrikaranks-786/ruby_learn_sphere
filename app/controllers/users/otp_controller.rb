class Users::OtpController < DeviseController
  protect_from_forgery except: :verify_otp
  
  def generate_otp
    user = User.find_by(email: params[:email])
    if user
      otp = user.generate_otp
      # Send OTP via email
      OtpMailer.send_otp(user, otp).deliver_now
      render json: { message: 'OTP has been sent to your email' }
    else
      render json: { error: 'User not found' }, status: :not_found
    end
  end

  def verify_otp
    user = User.find_by(email: params[:email])
    if user && user.valid_otp?(params[:otp])
      sign_in(user)
      render json: { 
        message: 'Successfully verified', 
        redirect_url: after_sign_in_path_for(user)
      }
    else
      render json: { error: 'Invalid OTP' }, status: :unprocessable_entity
    end
  end
end