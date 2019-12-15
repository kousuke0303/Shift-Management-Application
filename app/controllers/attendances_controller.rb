class AttendancesController < ApplicationController
  before_action :logged_in_user
  
  def index
    debugger
  end
  
  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    # 出勤時間が未登録であることを判定します。
    if @attendance.work_start_time.nil?
      if @attendance.update_attributes(work_start_time: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = "勤怠登録に失敗しました。やり直してください。"
      end
    end
    render :edit
  end
end
