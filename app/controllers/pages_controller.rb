class PagesController < ApplicationController
  def home
    redirect_to signin_path and return unless signed_in?
    if signed_in?
      @stream = current_user.stream.paginate(page: params[:page])
      unless request.xhr?
        @post = current_user.posts.build
      else
        render partial: "posts/post", collection: @stream
      end
    end
  end
end
