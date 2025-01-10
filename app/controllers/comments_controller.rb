class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    @lesson = Lesson.find(params[:lesson_id])
    @post = @lesson.post
    @comment = @post.comments.new(comment_params)
    @comment.user = current_user
    @comment.lesson = @lesson

    if @comment.save
      redirect_to post_lesson_path(@post, @lesson), notice: 'Comment added successfully!'
    else
      redirect_to post_lesson_path(@post, @lesson), alert: 'Failed to add comment.'
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end
end
