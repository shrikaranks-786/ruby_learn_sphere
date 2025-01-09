class LessonsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_lesson, only: %i[ show edit update destroy ]
  before_action :set_post, except: [ :chatbot_ask ]
  # GET /lessons or /lessons.json
  def index
    @lessons = Lesson.all
  end

  # GET /lessons/1 or /lessons/1.json
  def show
    @completed_lessons = current_user.lesson_users.where(completed:true).pluck(:lesson_id)
    @post = @lesson.post
    @lesson = Lesson.find(params[:id])
  end

  # GET /lessons/new
  def new
    @lesson = Lesson.new
  end

  # GET /lessons/1/edit
  def edit
  end

  # POST /lessons or /lessons.json
  def create
    @lesson = Lesson.new(lesson_params)

    respond_to do |format|
      if @lesson.save
        format.html { redirect_to @lesson, notice: "Lesson was successfully created." }
        format.json { render :show, status: :created, location: @lesson }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @lesson.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lessons/1 or /lessons/1.json
  def update
    @lesson_user = LessonUser.find_or_create_by(user: current_user, lesson: @lesson)
    @lesson_user.update!(completed: true)
    next_lesson = @post.lessons.where("position > ?",@lesson.position).order(:position).first
    if next_lesson
      redirect_to post_lesson_path(@post, next_lesson)
    else
      redirect_to post_path(@post), notice: "You've completed the Post"
    end
  end

  # DELETE /lessons/1 or /lessons/1.json
  def destroy
    @lesson.destroy!

    respond_to do |format|
      format.html { redirect_to lessons_path, status: :see_other, notice: "Lesson was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # POST /posts/:post_id/lessons/:id/unlock_course
  def unlock_course
    @post = Post.find(params[:post_id])

    # Create or update the user's access to the post
    current_user.posts << @post unless current_user.posts.include?(@post)

    # Update the paid_for_course attribute
    @post.update(paid_for_course: true)

    # Reload the post to get the updated attributes
    @post.reload

    respond_to do |format|
      format.html { redirect_to post_path(@post), notice: "Course unlocked successfully." }
      format.json { head :no_content }
    end
  end

  def chatbot_ask
    @lesson = Lesson.find_by(id: params[:id])
    question = params[:question]
  
    if @lesson.nil? || question.blank?
      render json: { error: "Invalid lesson or question." }, status: :unprocessable_entity
      return
    end
  
    @groq_response = fetch_groq_response(question)
  
    if @groq_response.present?
      render json: { response: @groq_response }, status: :ok
    else
      render json: { error: "No response from Groq." }, status: :internal_server_error
    end
  end
  
  
  private
  # Use callbacks to share common setup or constraints between actions.
  def set_post
    @post = Post.find(params[:post_id])
  end
  def set_lesson
    @lesson = Lesson.find(params.expect(:id))
  end
  
  # Only allow a list of trusted parameters through.
  def lesson_params
    params.expect(lesson: [ :title, :description, :paid, :post_id ])
  end

  def fetch_groq_response(question)
    api_url = "https://api.groq.com/openai/v1/chat/completions"
    api_key = "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"
  
    messages = [
      { role: "user", content: question }
    ]
  
    model = "llama-3.3-70b-versatile"
  
    response = HTTParty.post(api_url, 
      headers: {
        "Authorization" => "Bearer #{api_key}",
        "Content-Type" => "application/json"
      },
      body: {
        model: model,
        messages: messages
      }.to_json
    )
  
    # Log the response for debugging
    if response.success?
      response_body = response.parsed_response
      Rails.logger.debug("Groq API Response Body: #{response_body}")
      return response_body.dig("choices", 0, "message", "content") || "No response from Groq."
    else
      Rails.logger.error("Error: Unable to fetch response from Groq. Status: #{response.code}")
      return "Error: Unable to fetch response from Groq."
    end
  end
end
