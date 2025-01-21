class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: %i[show edit update destroy]

  def index
    @categories = Post.distinct.pluck(:category)
    @trending_courses = fetch_trending_courses
    @popular_courses = fetch_popular_courses
    @most_bought_courses = fetch_most_bought_courses

    @posts = Post.all

    @posts = @posts.where(category: params[:category]) if params[:category].present?

    case params[:price_order]
    when "low_to_high"
      @posts = @posts.order(price: :asc)
    when "high_to_low"
      @posts = @posts.order(price: :desc)
    end

    @query = params[:query]
    @posts = Post.where(title: @query) if @query.present?

    @user_started_courses = current_user&.lesson_users&.joins(:lesson)&.pluck(:post_id)&.uniq
    if @user_started_courses.present?
      @user_course_progresses = @user_started_courses.map do |post_id|
        course_lessons = Post.find(post_id).lessons.count
        completed_lessons = current_user&.lesson_users&.joins(:lesson)&.where(completed: true, lesson: { post: post_id })&.count
        { post_id: post_id, completed_percentage: (completed_lessons.to_f / course_lessons.to_f * 100).to_i }
      end
    end
  end

  def show
    @completed_lessons = current_user&.lesson_users&.joins(:lesson)&.where(completed: true, lessons: { post: @post })&.pluck(:lesson_id)
  end

  def new
    @post = Post.new
  end

  def edit
  end

  def create
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: "Post was successfully created." }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: "Post was successfully updated." }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @post.destroy!

    respond_to do |format|
      format.html { redirect_to posts_path, status: :see_other, notice: "Post was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def fetch_trending_courses
    Post.trending_by_tags(3)
  end

  def fetch_popular_courses
    Post.joins(:ratings)
        .group("posts.id")
        .select("posts.*, AVG(ratings.score) as avg_rating")
        .order("AVG(ratings.score) DESC")
        .limit(3)
  end

  def fetch_most_bought_courses
    Post.where("unlock_count > 0")
        .order(unlock_count: :desc)
        .limit(3)
  end

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :description, :category, :price)
  end
end