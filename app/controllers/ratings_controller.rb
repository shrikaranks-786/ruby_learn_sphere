class RatingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post
  
  def create
    @rating = current_user.ratings.build(rating_params.merge(post: @post))
    
    if @rating.save
      redirect_to @post, notice: 'Rating submitted successfully!'
    else
      redirect_to @post, alert: @rating.errors.full_messages.join(', ')
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def rating_params
    params.require(:rating).permit(:score)
  end
end
