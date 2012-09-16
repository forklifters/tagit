class PasswordResetsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_email!(params[:email])
    user.send_password_reset
    redirect_to signin_url, notice: t(:password_reset_sent_message) % { email: params[:email] }
  end

  def edit
    @user = User.find_by_password_reset_token!(params[:id])
  end

  def update
    @user = User.find_by_password_reset_token!(params[:id])
    if @user.password_reset_sent_at < 1.hour.ago
      redirect_to new_password_reset_path, alert: t(:password_reset_expired_message)
    elsif @user.update_attributes(params[:user])
      redirect_to root_url, notice: t(:password_reset_message)
    else
      render :edit
    end
  end
end
