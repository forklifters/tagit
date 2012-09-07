class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.where("username = ? OR email = ?", params[:email], params[:email].downcase).first
    if user && user.authenticate(params[:password])
      sign_in user
      redirect_back_or_to user
    else
      flash.now[:error] = t(:invalid_login_message)
      render "sessions/new"
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end
end
