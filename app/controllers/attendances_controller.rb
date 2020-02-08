class AttendancesController < ApplicationController
  before_action :logged_in_user
  
  def register
    # 管理者でログインした場合、出退勤登録画面に移動する
    if current_user.admin
      # 6は現在日付の朝6時を示す
      if Time.current < (Time.current.beginning_of_day + 6.hour)
        # -1は現在日付から見て昨日の日付を示す
        @attendance_staff_lists = Attendance.where(day: (Date.current - 1)..Time.current).paginate(page: params[:page])
      else
        @attendance_staff_lists = Attendance.where(day: Date.current).paginate(page: params[:page])
      end
      # 検索があった場合
      if (params[:input_id].present?) && (params[:input_id] != "") && (params[:input_password].present?) && (params[:input_password] != "")
        # 検索で合致した従業員情報を取得
        @attendance_staff = User.find(params[:input_id]).authenticate(params[:input_password])
        if @attendance_staff
          # 検索で合致した従業員の勤怠情報を取得
          @attendances = Attendance.where(user_id: @attendance_staff.id).where(day: Date.current)
        else
          # 検索で従業員情報が合致しない場合のメッセージ
          flash.now[:info] = 'IDとパスワードの組み合わせが不正です。'
        end
      end
    else
      # 従業員でログインした場合、シフト確認画面に移動する
      redirect_to shifts_current_shifts_user_path(current_user.id)
    end
  end
  
  def create
    # 出勤ボタン押下時にレコードが生成される
    @attendance = Attendance.new(day: Date.current, user_id: params[:user_id], work_start_time: Time.current.change(sec: 0))
    if @attendance.save
      flash[:info] = "おはようございます！"
    else
      flash[:danger] = "勤怠登録に失敗しました。やり直してください。"
    end
    redirect_to users_attendances_register_path(current_user)
  end
  
  def update
    # 退勤ボタン押下時、その日のレコードのwork_end_timeをupdateする
    @attendances = Attendance.where(user_id: params[:user_id]).where(day: Date.current)
    # 出勤時間が未登録であることを判定します。
    if @attendances[0].work_end_time.nil?
      if @attendances[0].update_attributes(work_end_time: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした！"
      else
        flash[:danger] = "勤怠登録に失敗しました。やり直してください。"
      end
    end
    redirect_to users_attendances_register_path(current_user)
  end
  
  def breakstart
    # 休憩開始ボタン押下時、その日のレコードのbreak_start_timeに現在時刻を挿入する
    @attendances = Attendance.where(user_id: params[:id]).where(day: Date.current)
    # 休憩開始時間が未登録であることを判定
    if @attendances[0].break_start_time.nil?
      if @attendances[0].update_attributes(break_start_time: Time.current.change(sec: 0))
        flash[:info] = "休憩を開始しました。"
      else
        flash[:danger] = "休憩開始に失敗しました。やり直してください。"
      end
    end
    redirect_to users_attendances_register_path(current_user)
  end
  
  def breakend
    # 休憩終了ボタン押下時、その日のレコードのbreak_end_timeに現在時刻を挿入する
    @attendances = Attendance.where(user_id: params[:id]).where(day: Date.current)
    # 休憩開始時間が未登録であることを判定します。
    if @attendances[0].break_end_time.nil?
      if @attendances[0].update_attributes(break_end_time: Time.current.change(sec: 0))
        flash[:info] = "休憩を終了しました。"
      else
        flash[:danger] = "休憩終了に失敗しました。やり直してください。"
      end
    end
    redirect_to users_attendances_register_path(current_user)
  end
end
