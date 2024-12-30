class Admin::PostsController < AdminController
  def index
    @admin_posts = Post.all
  end
end
