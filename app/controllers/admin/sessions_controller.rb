# app/controllers/admins/sessions_controller.rb
class Admin::SessionsController < Devise::SessionsController
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:email, :password, :otp, :remember_me])
  end

  def create
    admin = Admin.find_by(email: params[:admin][:email])
    
    if admin.present?
      if params[:admin][:otp].present?
        if admin.valid_otp?(params[:admin][:otp])
          sign_in(admin)
          admin.clear_otp if admin.respond_to?(:clear_otp)
          redirect_to after_sign_in_path_for(admin), notice: "Logged in successfully with OTP."
        else
          redirect_to new_admin_session_path, alert: "Invalid OTP."
        end
      elsif admin.valid_password?(params[:admin][:password])
        sign_in(admin)
        redirect_to after_sign_in_path_for(admin), notice: "Logged in successfully."
      else
        redirect_to new_admin_session_path, alert: "Invalid email or password."
      end
    else
      redirect_to new_admin_session_path, alert: "Admin not found."
    end
  end
end