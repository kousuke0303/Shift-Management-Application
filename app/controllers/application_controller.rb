class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  include ShiftsHelper
  
  $days_of_the_week = %w{日 月 火 水 木 金 土}
  
  def logged_in_user
    unless logged_in?
      store_location
      redirect_to login_url
    end
  end
  
  def correct_user
    redirect_to(root_url) unless current_user?(@user)
  end
  
  def admin_user
    redirect_to root_url unless current_user.admin?
  end
  
  def set_user
    @user = User.find(params[:id])
  end
  
  # 年月検索・年月日検索・スタッフ検索するときに必要となる処理
  def attendance_staff_day_search
    #月が10月以降の時と、10月以前で年月日検索を条件分岐
    if Attendance.find_by(params[:user_id]).present? && Attendance.find_by(params[:user_id]).day.to_date.month >= 10
      @attendances = Attendance
                     .where("user_id IN (?)", Attendance.find_by(params[:user_id]))
                     .where("day LIKE ?", "#{params['day(1i)']}" << "-" + "#{params['day(2i)']}%")
                     .or(Attendance.where(day: params[:day]))
                     .order("day")
    else
      @attendances = Attendance
                     .where("user_id IN (?)", Attendance.find_by(params[:user_id]))
                     .where("day LIKE ?", "#{params['day(1i)']}" << "-0" + "#{params['day(2i)']}%")
                     .or(Attendance.where(day: params[:day]))
                     .order("day")
    end
  end
  
  def set_attendance_user_id
    @user = User.find(@attendance.user_id)
  end
  
  def set_attendance
    @attendance = Attendance.find(params[:id])
  end
  
  def set_staff
    #管理者を除いたスタッフを出力
    @staffs = User.where(admin: false)
  end
end
