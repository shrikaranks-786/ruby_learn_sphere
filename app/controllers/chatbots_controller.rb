class ChatbotsController < ApplicationController
  def index
    @chatbots = Chatbot.all.order(created_at: :asc)
    @new_question = Chatbot.new
    render :chatbot
  end

  def create
    question = params[:chatbot][:question]
    Rails.logger.info "Received question: #{question}"

    answer = fetch_groq_response(question)
    Rails.logger.info "Received answer: #{answer}" 

    if answer.present?
      @chatbot = Chatbot.create(question: question, answer: answer)
    else
      @chatbot = Chatbot.new(question: question, answer: "Sorry, I couldn't generate a response.")
    end

    @chatbots = Chatbot.all.order(created_at: :asc)
    @new_question = Chatbot.new

    if @chatbot.persisted?
      flash[:notice] = "Question and answer saved successfully!"
      Rails.logger.info "Chatbot saved successfully."
      redirect_to chatbot_path 
    else
      flash[:error] = "Failed to save chatbot response."
      Rails.logger.error "Failed to save chatbot: #{@chatbot.errors.full_messages.join(', ')}"
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("chat-input", partial: "chatbots/form", locals: { new_question: @new_question }) }
        format.html { render :chatbot }
      end
    end
  end

  private

  def fetch_groq_response(question)
    api_url = "https://api.groq.com/openai/v1/chat/completions"
    api_key = "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"
  
    posts = Post.all
    post_details = posts.map do |post|
      "Post ID: #{post.id}, Title: #{post.title}, Description: #{post.description}"
    end.join("\n")
    prompt = "Here are all the posts:\n#{post_details}\n\nUser Question: #{question}"
    messages = [
      { role: "user", content: question + prompt }
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
  
    if response.success?
      response_body = response.parsed_response
      return response_body.dig("choices", 0, "message", "content") || "No response from Groq."
    else
      return "Error: Unable to fetch response from Groq."
    end
  end  
end
