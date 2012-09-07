module SessionsHelper
  def sign_in(user)
    cookies.permanent[:remember_token] = user.remember_token
    self.current_user = user
  end
  
  def sign_out
    self.current_user = nil
    cookies.delete(:remember_token)
  end
  
  def signed_in?
    !current_user.nil?
  end
  
  def ensure_signed_in
    unless signed_in?
      store_location
      flash[:notice] = t(:deny_access_message)
      redirect_to signin_url
    end
  end
  
  def current_user
    @current_user ||= User.find_by_remember_token(cookies[:remember_token])
  end
  def current_user=(user)
    @current_user = user
  end
  def current_user?(user)
    user == current_user
  end
  
  def redirect_back_or_to(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location
    session[:return_to] = request.url
  end
end
