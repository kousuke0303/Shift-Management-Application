class SessionsController < ApplicationController
  def new
  end
  
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      log_in user
      params[:session][:remember_me] == "1" ? remember(user) : forget(user)
      if !user.admin
        redirect_to shifts_current_shifts_user_url(user)
      else
        redirect_to users_attendances_register_url(user)
      end
    else
      flash[:danger] = "認証に失敗しました。"
      render :new
    end
  end
  
  def destroy
    log_out if logged_in?
    flash[:success] = "ログアウトしました。"
    redirect_to root_url
  end
end