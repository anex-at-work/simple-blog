class PostsController < ApplicationController
  before_filter :check_user_logged_in, except: [:index, :show]
  before_filter :set_editable_post, only: [:edit, :destroy, :update]

  def index
    @posts = Post.avaliable(current_user).order('published_at desc')
    if params[:user_id].present?
      @posts = @posts.where(user_id: params[:user_id])
      @user_post = User.find(params[:user_id])
    elsif params[:tag_id].present?
      @posts = @posts.tagged_with(params[:tag_id])
    end
    @posts = @posts.page(params[:page] || 0)
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.create post_params
    if !@post.valid?
      render action: :new
    else
      @post.user = current_user
      @post.save
      redirect_to action: :index
    end
  end

  def show
    @post = Post.avaliable(current_user).find params[:id]
    @new_comment = Comment.new if user_signed_in?
    @comments = Comment.where(post_id: params[:id]).with_user.order(:lft)
  end

  def edit
  end

  def destroy
    @post.delete
    redirect_to action: :index
  end

  def update
    @post.update post_params
    if !@post.valid?
      render action: :edit
    else
      redirect_to action: :index
    end
  end

  def tags
    respond_to do |format|
      format.json do
        length = 30
        page = params[:page] || 0
        tags = ActsAsTaggableOn::Tag.where('name ILIKE ?', %(%#{params[:q]}%)).
          page(1).offset(page*length).order(:name)

        render json: {items: tags.map{|t| {id: t.name, name: t.name}}.push({id: params[:q], name: params[:q]}),
          total_count: tags.count + 1
        }
      end
    end
  end

  private
  def post_params
    params.require(:post).permit :name, :content, :published_at, :status, tag_list: []
  end

  def check_user_logged_in
    redirect_to new_user_session_path if !user_signed_in?
  end

  def set_editable_post
    @post = Post.avaliable(current_user).find params[:id]
    raise ActiveRecord::RecordNotFound if !@post.can_edit_by? current_user
  end
end
