class PagesController < ApplicationController
  def home
    redirect_to signin_path and return unless signed_in?
    @stream = current_user.stream.paginate(page: params[:page])
    if request.xhr?
      render partial: "posts/post", collection: @stream
    else
      @post = current_user.posts.build
    end
  end
end
