class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,:otp_authenticatable
  
         def generate_otp
          new_otp = SecureRandom.random_number(100000..999999).to_s
          update(
            otp: new_otp,
            otp_generated_at: Time.current
          )
          new_otp
        end
      
        def valid_otp?(entered_otp)
          return false if otp.blank? || otp_generated_at.blank?
          return false if otp_generated_at < 5.minutes.ago # OTP expires after 5 minutes
          return false if entered_otp.blank?
          
          otp == entered_otp
        end
      
        def clear_otp
          update(otp: nil, otp_generated_at: nil)
        end
end
