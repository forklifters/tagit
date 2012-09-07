class UsersController < ApplicationController
  before_filter :ensure_signed_in, only: [:edit, :update]
  before_filter :authorize_edit, only: [:edit, :update]
  before_filter :authorize_destroy, only: :destroy
  
  respond_to :html, :js
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = t(:welcome_message)
      redirect_to @user
    else
      render "users/new"
    end
  end
  
  def index
    query = "#{params[:search]}%"
    @users = User.where("LOWER(username) LIKE LOWER(?) OR LOWER(name) LIKE LOWER(?)", query, query).order("created_at DESC").paginate(page: params[:page])
    if request.xhr?
     render "users/search", users: @users
    end
  end
  
  def show
    @user = User.find(params[:id])
    @stream = @user.stream.paginate(page: params[:page])
  end
  
  def edit
  end
  
  def update
    if @user.update_attributes(params[:user])
      flash[:success] = t(:profile_updated_message)
      sign_in @user
      redirect_to @user
    else
      render "users/edit"
    end
  end
  
  def following
    show_follow(:following)
  end

  def followers
    show_follow(:followers)
  end

  def show_follow(action)
    @title = t[action.to_s]
    @user = User.find(params[:id])
    @users = @user.send(action).paginate(page: params[:page])
    render "users/show_relationships"
  end
  
  def settings
    # if !params[:collapse_post].nil? && !params[:post_id].nil?
      # @collapse_post = (params[:collapse_post] == "true")
      # post_id_int = params[:post_id].to_i
      # @post = Post.find_by_id(post_id_int)
      # unless @post.nil?
        # current_user.settings.collapsed_posts = [] if current_user.settings.collapsed_posts.nil?
        # if @collapse_post
          # current_user.settings.collapsed_posts += [post_id_int] unless current_user.settings.collapsed_posts.include?(post_id_int)
        # else
          # current_user.settings.collapsed_posts -= [post_id_int]
        # end
      # end
      # respond_with @collapse_post, @post
    # end
  end
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = t(:user_deleted_message)
    redirect_to users_url
  end
  
private
  def authorize_edit
    @user = User.find(params[:id])
    redirect_to root_path unless current_user?(@user)
  end
  
  def authorize_destroy
    @user = User.find(params[:id])
    unless current_user.admin? && !@user.admin?
      flash[:error] = t(:deny_access_message)
      redirect_to root_path
    end
  end
end
