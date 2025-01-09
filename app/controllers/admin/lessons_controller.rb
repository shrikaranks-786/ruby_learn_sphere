class Admin::LessonsController < Admin::AdminController
  before_action :set_post
  before_action :set_lesson, only: [ :show, :edit, :update, :destroy ]

  def index
    @admin_lessons = @admin_post.lessons.order(:position)
  end

  def new
    @admin_lesson = @admin_post.lessons.new 
  end

  def show
    
  end

  def edit
    
  end

  def update
    if @admin_lesson.update(lesson_params)
      redirect_to admin_post_lessons_path(@admin_post)
    else
      render :edit
    end
  end

  def create
    @admin_lesson = @admin_post.lessons.new(lesson_params)

    if @admin_lesson.save
      redirect_to admin_post_lessons_path(@admin_post)
    else
      render :new
    end
  end

  def destroy
    @admin_lesson.destroy!
    redirect_to admin_post_lessons_path(@admin_post), notice: "Lesson was successfully destroyed."
  end

  private

  def lesson_params
    params.require(:lesson).permit(:title, :description, :video, :paid, :position)
  end

  def set_post
    @admin_post = Post.find(params[:post_id])
  end

  def set_lesson
    @admin_lesson = Lesson.find(params[:id])
  end
end