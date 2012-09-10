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
    post_tag = PostTag.find_by_id(params[:id]) || not_found
    @post = post_tag.post
    @tag = post_tag.tag
    post_tag.destroy
    respond_with @post, @tag
  end
end
