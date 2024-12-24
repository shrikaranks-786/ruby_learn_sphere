class ApplicationController < ActionController::Base
  before_action :authenticate_user! # Global authentication

  # Skip authentication for landing action explicitly
  skip_before_action :authenticate_user!, if: -> { params[:controller] == "pages" && params[:action] == "landing" }
end
