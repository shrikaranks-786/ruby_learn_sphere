class UnlocksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post

  def create
    @post.increment_unlock_count!
    redirect_to @post, notice: 'Course unlocked successfully!'
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end
end