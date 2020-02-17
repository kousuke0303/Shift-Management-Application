class UsersController < ApplicationController
  include UsersHelper

  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_user_info, :update_user_info]
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :edit_user_info, :update_user_info]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy, :edit_user_info, :update_user_info]
  
  def index
    @users = User.where(admin: false).paginate(page: params[:page])
  end
    
  def show
    @attendance = @user.attendances.find_by(params[:id])
  end

  def new
    @user = User.new 
    # @user.attendances.build
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "新規作成に成功しました。"
      redirect_to @user
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      render :edit      
    end
  end
  
  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end
  
  def edit_user_info
  end

  def update_user_info
    if @user.update_attributes(update_user_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
    else
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :admin, :leader, :kitchen, :hole, :wash, :password, :password_confirmation, :hourly_wage)
    end
    
    def update_user_info_params
      params.require(:user).permit(:email, :admin, :kitchen, :hole, :wash, :hourly_wage)
    end
    
    def set_user
      @user = User.find(params[:id])
    end
end
