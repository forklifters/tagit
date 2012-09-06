class PagesController < ApplicationController
  def home
    redirect_to signin_path unless signed_in?
  end
end
