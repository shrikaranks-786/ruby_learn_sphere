class PagesController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: [ :landing ] # Landing action doesn't require authentication

  def landing
    if user_signed_in?
      redirect_to lobby_path # Redirect authenticated users to posts#index
    end
  end
end
