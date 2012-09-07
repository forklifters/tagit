class PagesController < ApplicationController
  def home
    redirect_to signin_path and return unless signed_in?
    @post = current_user.posts.build
    @stream = current_user.stream.paginate(page: params[:page])
  end
end
