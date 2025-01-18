class Users::SessionsController < Devise::SessionsController
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:email, :password, :otp, :remember_me])
  end

  def create
    user = User.find_by(email: params[:user][:email])
    
    if user.present?
      if params[:user][:otp].present?
        if user.valid_otp?(params[:user][:otp])
          sign_in(user)
          user.clear_otp if user.respond_to?(:clear_otp)
          redirect_to after_sign_in_path_for(user), notice: "Logged in successfully with OTP."
        else
          redirect_to new_user_session_path, alert: "Invalid OTP."
        end
      elsif user.valid_password?(params[:user][:password])
        sign_in(user)
        redirect_to after_sign_in_path_for(user), notice: "Logged in successfully."
      else
        redirect_to new_user_session_path, alert: "Invalid email or password."
      end
    else
      redirect_to new_user_session_path, alert: "User not found."
    end
  end
end
