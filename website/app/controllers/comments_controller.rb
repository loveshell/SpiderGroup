class CommentsController < ApplicationController

  def create
    commentable = params[:comment][:commentable_type].constantize.find(params[:comment][:commentable_id])
    if authenticate_user!

      begin
        authorize! :create, :Comment

        comment = Comment.new comment_params
        comment.commentable = commentable
        comment.user = current_user
        comment.save
      rescue CanCan::AccessDenied => e
        redirect_to commentable, alert:"error"
        return
      end

    end
    redirect_to commentable

  end


  private

  def comment_params
    params.require(:comment).permit!
  end
end