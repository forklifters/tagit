class PostsController < ApplicationController
  before_filter :ensure_signed_in, only: [:create, :destroy]
  before_filter :authorize_edit, only: [:edit, :update, :destroy]

  respond_to :html, :js

  def create
    if params[:commit] == t(:post_verb)
      post = params[:post]
      @post = current_user.posts.build(title: post[:title], content: post[:content])
      if @post.save
        @post.tag_with_list(post[:tag_list], current_user)
        respond_with @post
      else
        if @post.valid?
          flash[:error] = t(:post_failed_message)
        else
          flash[:error] = @post.errors.full_messages
        end
        @post = nil
        respond_with @post
      end
    elsif params[:commit] == t(:search_verb) # Search stream
      search
    end
  end
  
  def search
    post = params[:post] || params
    if post.all? &:blank? # No search parameters - reset to default
      @stream = current_user.stream.paginate(page: params[:page])
      session.delete(:search_params)
    else
      if !params[:page]
        session[:search_params] = post
      else
        post = session[:search_params]
      end
      title = "%#{post[:title]}%";
      content = "%#{post[:content]}%";
      tag_names = post[:tag_list].split(/,\s*/).map(&:downcase)
      if tag_names.blank?
        @stream = current_user.stream
          .where('LOWER("posts".title) LIKE LOWER(?) AND LOWER("posts".content) LIKE LOWER(?)', title, content)
          .paginate(page: params[:page])
      else
        tag_ids = Tag.select('id').where('LOWER(name) in (?)', tag_names)
        if tag_ids.blank?
          @stream = []
        else
          @stream = current_user.stream
            .where('
              LOWER("posts".title) LIKE LOWER(?) AND
              LOWER("posts".content) LIKE LOWER(?) AND
              (SELECT COUNT(DISTINCT "post_tags".tag_id)
              FROM "post_tags"
              WHERE "post_tags".post_id = "posts".id AND "post_tags".tag_id IN (?)) = ?', title, content, tag_ids, tag_ids.length)
            .paginate(page: params[:page])
        end
      end
    end
    
    if params[:page]
      render partial: "posts/post", collection: @stream
    else
      respond_with @stream
    end
  end

  def show
    @post = Post.find_by_id(params[:id]) || not_found
  end

  def edit
    @post = Post.find_by_id(params[:id]) || not_found
    respond_with @post
  end

  def update
    @post = Post.find_by_id(params[:id]) || not_found
    post = params[:post]
    if @post.update_attributes(title: post[:title], content: post[:content])
      @post.tag_with_list(post[:tag_list], current_user)
      respond_with @post
    else
      if @post.valid?
        flash[:error] = t(:post_failed_message)
      else
        flash[:error] = @post.errors.full_messages
      end
      @post = nil
      respond_with @post
    end
  end

  def destroy
    @post_id = @post.id
    @post.destroy
    respond_with @post_id
  end

private
  def authorize_edit
    @post = current_user.posts.find_by_id(params[:id]) || not_found
  end
end
