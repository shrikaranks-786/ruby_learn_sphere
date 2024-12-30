class AdminController < ApplicationController
    layout "admin" # Ensure this points to the correct layout file
    before_action :authenticate_admin!
    def index
    end
end