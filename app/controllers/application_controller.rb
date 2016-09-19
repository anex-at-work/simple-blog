class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  before_action :configure_permitter_parameters, if: :devise_controller?
  before_filter :set_tags

  def render_404
    render '404', status: 404
  end

  protected
  def configure_permitter_parameters
    devise_parameter_sanitizer.permit :sign_up,
      keys: [:username, :email, :password, :password_confirmation, :remember_me]
  end

  private
  def set_tags
    @tags = ActsAsTaggableOn::Tag.all.eager_load(:taggings).
      where(taggings: {taggable_id: Post.avaliable(current_user).select(:id)})
  end
end
