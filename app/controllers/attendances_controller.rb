class AttendancesController < ApplicationController
  before_action :logged_in_user
  
  #給与管理
  def salary_management
    #勤怠情報が存在している情報のみ出力
    @attendances = Attendance.where.not(day: params["date"], work_start_time: nil, break_start_time: nil, break_end_time: nil, work_end_time: nil).includes(:user)
  end
  
  #給与合計を算出するために実労働時間を算出するロジック
  def total_time(start_time, start_break_time, finish_break_time, finish_time)
    (((finish_time + (start_break_time - finish_break_time) - start_time / 60 ) / 60.0))
  end
  
  def register
    # 今日出勤済みかどうか調べる
    if Attendance.find_by(user_id: current_user.id, day: Date.today)
      # 出勤済みでなければ自分のユーザIDの今日日付のレコードを抽出
      @attendance = Attendance.where(user_id: current_user.id).where(day: Date.today)
    end
  end
  
  def create
    # 今日出勤済みかどうか調べる
    if Attendance.find_by(user_id: current_user.id, day: Date.today)
      flash[:info] = "今日はもう出勤済みです。"
      redirect_to users_attendances_register_path(current_user)
    else
      # 出勤ボタン押下時にレコードが生成される
      # 日本時間に合わせる為、9時間分の秒数を足す
      @attendance = Attendance.new(day: Date.today, user_id: current_user.id, work_start_time: Time.current.change(sec: 0) + 32400)
      if @attendance.save
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = "勤怠登録に失敗しました。やり直してください。"
      end
      redirect_to users_attendances_register_path(current_user)
    end
  end
  
  def update
    # 退勤ボタン押下時、その日のレコードのwork_end_timeをupdateする
    @attendance = Attendance.where(user_id: current_user.id).where(day: Date.today)
    # 出勤時間が未登録であることを判定します。
    if @attendance[0].work_end_time.nil?
      if @attendance[0].update_attributes(work_end_time: Time.current.change(sec: 0) + 32400)
        flash[:info] = "お疲れ様でした！"
      else
        flash[:danger] = "勤怠登録に失敗しました。やり直してください。"
      end
    end
    redirect_to users_attendances_register_path(current_user)
  end
  
  def breakstart
    # 休憩開始ボタン押下時、その日のレコードのbreak_start_timeに現在時刻を挿入する
    @attendance = Attendance.where(user_id: current_user.id).where(day: Date.today)
    # 休憩開始時間が未登録であることを判定します。
    if @attendance[0].break_start_time.nil?
      if @attendance[0].update_attributes(break_start_time: Time.current.change(sec: 0) + 32400)
        flash[:info] = "休憩を開始しました。"
      else
        flash[:danger] = "休憩開始に失敗しました。やり直してください。"
      end
    end
    redirect_to users_attendances_register_path(current_user)
  end
  
  def breakend
    # 休憩終了ボタン押下時、その日のレコードのbreak_end_timeに現在時刻を挿入する
    @attendance = Attendance.where(user_id: current_user.id).where(day: Date.today)
    # 休憩開始時間が未登録であることを判定します。
    if @attendance[0].break_end_time.nil?
      if @attendance[0].update_attributes(break_end_time: Time.current.change(sec: 0) + 32400)
        flash[:info] = "休憩を終了しました。"
      else
        flash[:danger] = "休憩終了に失敗しました。やり直してください。"
      end
    end
    redirect_to users_attendances_register_path(current_user)
  end
end
