class PagesController < ApplicationController
  def home
    redirect_to signin_path and return unless signed_in?
    @post = current_user.posts.build
    @posts = current_user.posts.paginate(page: params[:page])
  end
end
