class RatingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post

  def create
    if current_user.ratings.exists?(post: @post)
      redirect_to @post, alert: 'You have already rated this course'
      return
    end

    @rating = @post.ratings.build(rating_params)
    @rating.user = current_user

    if @rating.save
      redirect_to @post, notice: 'Rating was successfully added'
    else
      redirect_to @post, alert: 'Error adding rating'
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