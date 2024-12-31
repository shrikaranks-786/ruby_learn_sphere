class Admin::PostsController < AdminController
  def index
    @admin_posts = Post.all
  end

  def new
    @admin_post = Post.new
  end

  def create
    @admin_post = Post.new(post_params)

    if @admin_post.save
      redirect_to admin_post_path
    else
      render :new
    end
  end

  def edit
    @admin_post
  end

  private
  def post_params
    params.require(:post).permit(:title,:description,:paid,:image)
  end
end
