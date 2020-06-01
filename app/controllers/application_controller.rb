class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  include ShiftsHelper
  
  $days_of_the_week = %w{日 月 火 水 木 金 土}
  
  # ログイン状態でのみアクセス許可
  def logged_in_user
    unless logged_in?
      store_location
      redirect_to login_url
    end
  end
  
  # 一般ユーザーの、他のユーザーページへのアクセス制限
  def correct_user
    redirect_to(root_url) unless current_user?(@user)
  end
  
  # 管理者のみアクセス許可
  def admin_user
    redirect_to root_url unless current_user.admin?
  end
  
  # ログイン状態でのアクセス制限
  def reject_logged_in_user
    if logged_in? && current_user.admin?
      flash[:info] = "すでにログインしています。"
      redirect_to root_url
    elsif logged_in? && !current_user.admin?
      flash[:info] = "すでにログインしています。"
      redirect_to shifts_current_shifts_user_url(current_user)
    end
  end
  
  # 一般ユーザーのアカウント作成数制限
  def only_one_account_create
    if @user.present? && !current_user.admin?
      flash[:info] = "すでにアカウントを作成済です。"
      redirect_to shifts_current_shifts_user_url(current_user)
    end
  end
  
  def set_user
    @user = User.find(params[:id])
  end
  
  # 年月検索・年月日検索・スタッフ検索するときに必要となる処理
  def attendance_staff_day_search
    #月が10月以降の時と、10月以前で年月日検索を条件分岐
    if params[:user_id].present?
      if @attendance.present? && Attendances.find(params[:id]).day.to_date.month >= 10
        @attendances = Attendance
                       .where("user_id = (?)", params[:user_id])
                       .where("day LIKE ?", "#{params['day(1i)']}" << "-" + "#{params['day(2i)']}%")
                       .order("day")
      else
        @attendances = Attendance
                       .where("user_id = (?)", params[:user_id])
                       .where("day LIKE ?", "#{params['day(1i)']}" << "-0" + "#{params['day(2i)']}%")
                       .order("day")
      end
    else
      @attendances = Attendance.where(day: params[:day])    
    end
  end
  
  def set_attendance_user_id
    @user = User.find(@attendance.user_id)
  end
  
  def set_attendance
    @attendance = Attendance.find_by(params[:day])
  end
  
  def set_staff
    #管理者を除いたスタッフを出力
    @staffs = User.where(admin: false)
  end
end
