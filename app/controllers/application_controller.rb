class ApplicationController < ActionController::Base
  def after_sign_in_path_for(resource)
    if resource.is_a?(Admin)
      admin_admin_dashboard_path # Redirect to /admin
    else
      super
    end
  end
end
