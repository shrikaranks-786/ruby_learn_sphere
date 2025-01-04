# app/controllers/chatbots_controller.rb
class ChatbotsController < ApplicationController
  def index
    @chatbots = Chatbot.all.order(created_at: :asc)
    @new_question = Chatbot.new
    render :chatbot
  end

  def create
    question = params[:chatbot][:question]
    Rails.logger.info "Received question: #{question}" # Log the received question

    answer = fetch_groq_response(question)
    Rails.logger.info "Received answer: #{answer}" # Log the received answer

    # Check if the answer is valid before creating the Chatbot record
    if answer.present?
      @chatbot = Chatbot.create(question: question, answer: answer)
    else
      @chatbot = Chatbot.new(question: question, answer: "Sorry, I couldn't generate a response.")
    end

    # Ensure @chatbots is set to avoid nil errors
    @chatbots = Chatbot.all.order(created_at: :asc)
    @new_question = Chatbot.new # Initialize @new_question here

    if @chatbot.persisted?
      flash[:notice] = "Question and answer saved successfully!"
      Rails.logger.info "Chatbot saved successfully." # Log success
      redirect_to chatbot_path # Redirect to the index action or appropriate path
    else
      flash[:error] = "Failed to save chatbot response."
      Rails.logger.error "Failed to save chatbot: #{@chatbot.errors.full_messages.join(', ')}" # Log errors
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("chat-input", partial: "chatbots/form", locals: { new_question: @new_question }) }
        format.html { render :chatbot } # Render the form again if there's an error
      end
    end
  end

  private

  def fetch_groq_response(question)
    api_url = "https://api.groq.com/openai/v1/chat/completions"
    api_key = "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" # Assuming you've set the API key in environment variables
  
    # Set the message to send to Groq
    messages = [
      { role: "user", content: question }
    ]
  
    # Set the model you want to use (update this with the model from the documentation)
    model = "llama-3.3-70b-versatile"  # Change to the required model from the documentation
  
    # Send the request to Groq API
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
  
    # Check if the response is valid and return the response message
    if response.success?
      response_body = response.parsed_response
      return response_body.dig("choices", 0, "message", "content") || "No response from Groq."
    else
      return "Error: Unable to fetch response from Groq."
    end
  end  
end
