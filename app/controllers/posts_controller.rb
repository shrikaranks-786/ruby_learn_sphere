class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: %i[ show edit update destroy ]

  # GET /posts or /posts.json
  def index
    @categories = Post.distinct.pluck(:category) # Get unique categories
    if params[:category].present?
      @posts = Post.where(category: params[:category])
    else
      @posts = Post.all
    end
    # @user_unlocked_courses = current_user&.course_users&.pluck(:course_id)
    @user_started_courses = current_user&.lesson_users&.joins(:lesson)&.pluck(:post_id)&.uniq
    if @user_started_courses.present?
      @user_course_progresses = @user_started_courses.map do |post_id|
        course_lessons = Post.find(post_id).lessons.count
        completed_lessons = current_user&.lesson_users&.joins(:lesson)&.where(completed: true, lesson: { post: post_id })&.count
        { post_id: post_id, completed_percentage: (completed_lessons.to_f / course_lessons.to_f * 100).to_i }
      end
    end
  end

  # GET /posts/1 or /posts/1.json
  def show
    @completed_lessons = current_user&.lesson_users&.joins(:lesson)&.where(completed: true, lessons: { post: @post })&.pluck(:lesson_id)
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts or /posts.json
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

  # PATCH/PUT /posts/1 or /posts/1.json
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

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy!

    respond_to do |format|
      format.html { redirect_to posts_path, status: :see_other, notice: "Post was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.expect(post: [ :title, :description ])
    end
end
