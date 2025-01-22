class AddOtpFieldsToAdmins < ActiveRecord::Migration[8.0]
  def change
    add_column :admins, :otp, :string
    add_column :admins, :otp_generated_at, :datetime
  end
end
