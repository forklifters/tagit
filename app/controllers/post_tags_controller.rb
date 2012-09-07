class PostTagsController < ApplicationController
  respond_to :html, :js
  
  def create
    @post = Post.find(params[:post_id])
    if (params[:add_tags])
      @post.tag_with_list(params[:added_tags], current_user, false)
    else
      tag = Tag.find(params[:tag_id])
      @post.tag!(tag, current_user)
    end
    respond_with @post
  end
  
  def destroy
    post_tag = PostTag.find_by_id(params[:id])
    flash[:error] = t(:record_not_found_message) and return if post_tag.nil?
    @post = post_tag.post
    @tag = post_tag.tag
    post_tag.destroy
    respond_with @post, @tag
  end
end
