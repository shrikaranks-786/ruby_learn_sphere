class Admin::PostsController < AdminController
  def index
    @admin_posts = Post.all
  end

  def show
    @admin_post = Post.find(params[:id])
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
    @admin_post = Post.find(params[:id])
  end

  def update
    @admin_post = Post.find(params[:id])

    if @admin_post.update(post_params)
      redirect_to admin_posts_path
    else
      render :edit
    end
  end

  private
  def post_params
    params.require(:post).permit(:title,:description,:paid,:image)
  end
end
