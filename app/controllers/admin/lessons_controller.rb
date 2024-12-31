class Admin::LessonsController < AdminController
  before_action :set_post
  def index
    @admin_lessons = @admin_post.lessons.order(:position)
  end

  private

  def set_post
    @admin_post = Post.find(params[:post_id])
  end
end
