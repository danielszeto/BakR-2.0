class ApplicationController < ActionController::Base
  helper_method :current_user

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def login(user)
    reset_session
    session[:user_id] = user.id
  end

  def require_login
    redirect_to sign_in_path, alert: "Please sign in first." unless current_user
  end
end
