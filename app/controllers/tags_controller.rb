class TagsController < ApplicationController
  respond_to :html, :js
  
  def index
    name = "#{params[:name]}%"
    post_id = params[:post_id]
    if post_id.nil?
      @tags = Tag.select('name').where('LOWER(name) LIKE LOWER(?)', name)
    else
      @tags = Tag.select('name').where('LOWER(name) LIKE LOWER(?) AND id NOT IN (SELECT "post_tags".tag_id FROM "post_tags" WHERE "post_tags".post_id = ?)', name, post_id)
    end
    if request.xhr?
      render partial: 'tags/autocomplete_tag', collection: @tags.take(5), post_id: params[:post_id]
    end
  end
  
  def show
    @tag = Tag.find_by_slug(params[:id])
    @tag_posts = Post.where(id: @tag.posts.uniq).paginate(page: params[:page]) unless @tag.nil?
    flash[:error] = t(:record_not_found_message) if @tag.nil?
    if request.xhr?
      render partial: 'posts/post', collection: @tag_posts
    end
  end
  
  def destroy
    post = Post.find(params[:post_id]) unless params[:post_id].blank?
    current_user.post_tags.find_all_by_tag_id(params[:id]).each(&:destroy)
    redirect_back_or_to root_path
  end
end
