class CommentsController < ApplicationController
  respond_to :json, only: [:create, :update]
  before_filter :check_user_logged_in

  def edit
    @comment = editable_comment
    raise ActiveRecord::RecordNotFound and return if @comment.nil?
  end

  def create
    comment = Comment.create comment_params.merge(post_id: params[:post_id], user: current_user)
    if !comment.valid?
      render json: {errors: comment.errors}, status: :bad_request
    else
      render json: {success: true, location: post_path(params[:post_id], anchor: 'comments')}, status: :ok
    end
  end

  def update
    comment = editable_comment
    return if comment.nil?
    comment.update comment_params.except(:parent_id)
    if !comment.valid?
      render json: {errors: comment.errors}, status: :bad_request
    else
      render json: {success: true, location: post_path(params[:post_id], anchor: 'comments')}, status: :ok
    end
  end

  def destroy
    comment = editable_comment
    raise ActiveRecord::RecordNotFound and return if comment.nil?
    comment.delete
    redirect_to post_path(params[:post_id], anchor: 'comments')
  end

  private
  def check_user_logged_in
    render json: {error: I18n.t('messages.unauthorized')}, status: 401 and return if !user_signed_in?
  end

  def editable_comment
    comment = Comment.find(params[:id])
    if comment.nil? || !comment.can_edit_by?(current_user)
      if :json == request.format.to_sym
        render json: {error: I18n.t('messages.comment_not_editable')}, status: :not_found and return
      end
      return nil
    end
    comment
  end

  def comment_params
    params.require(:comment).permit :id, :parent_id, :comment
  end
end
