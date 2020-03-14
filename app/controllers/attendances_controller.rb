class AttendancesController < ApplicationController
  include AttendancesHelper

  before_action :logged_in_user
  before_action :attendance_staff_day_search, only:[:salary_management, :attendance_management]
  before_action :set_attendance, only: [:salary_management_info, :update_salary_management_info, :destroy, :attendance_management_info, :update_attendance_management_info, :attendance_management_notice, :update_attendance_management_notice] 
  before_action :set_attendance_user_id, only: [:salary_management_info, :update_salary_management_info, :destroy, :attendance_management_info, :update_attendance_management_info, :attendance_management_notice, :update_attendance_management_notice]
  before_action :set_staff, only:[:salary_management, :attendance_management, :new_attendance_management_info]

  #給与管理
  def salary_management
  end
  
  #出退勤管理
  def attendance_management
  end
  
  #出退勤管理出退勤編集モーダル
  def attendance_management_info
  end
  
  #出退勤管理モーダル内更新処理
  def update_attendance_management_info
    #下記の実装は、出退勤と休憩時間に矛盾が生じないようにするため
    if params[:attendance][:work_start_time].to_i < 10
      flash[:danger] = "勤務時間が10時以前は出勤登録できません"
      redirect_back(fallback_location: attendance_management)
    elsif params[:attendance][:work_start_time].present? && params[:attendance][:work_end_time].present? && params[:attendance][:work_start_time] > params[:attendance][:work_end_time] && (params[:attendance][:work_end_time].to_time.hour >= 2 && params[:attendance][:work_end_time].to_time.hour <= 23)
      flash[:danger] = "出勤時間より退勤時間の方が時間が早いです。"
      redirect_back(fallback_location: attendance_management)
    elsif params[:attendance][:work_start_time].present? && params[:attendance][:work_end_time].present? && params[:attendance][:work_start_time].to_time.hour == params[:attendance][:work_end_time].to_time.hour && (params[:attendance][:work_end_time].to_time.min - params[:attendance][:work_start_time].to_time.min) <= 15
      flash[:danger] = "出勤時間と退勤時間の差分で15分以内の場合は登録できません。"
      redirect_back(fallback_location: attendance_management)
    elsif params[:attendance][:break_start_time].present? && params[:attendance][:break_end_time].present? && params[:attendance][:break_end_time].present? && params[:attendance][:break_start_time] > params[:attendance][:break_end_time]
      flash[:danger] = "休憩開始時間より休憩終了時間の方が時間が早いです。"
      redirect_back(fallback_location: attendance_management)
    elsif params[:attendance][:break_start_time].blank? && params[:attendance][:break_end_time].present?
      flash[:danger] = "休憩開始時間を入力してください。"
      redirect_back(fallback_location: attendance_management)
    elsif params[:attendance][:work_start_time].present? && params[:attendance][:break_start_time].present? && params[:attendance][:break_start_time] < params[:attendance][:work_start_time] && (params[:attendance][:break_start_time].to_time.hour >= 2 && params[:attendance][:break_start_time].to_time.hour <= 23)
      flash[:danger] = "休憩開始時間よりも出勤時間の方が遅いです。"
      redirect_back(fallback_location: attendance_management)
    elsif params[:attendance][:work_start_time].present? && params[:attendance][:break_end_time].present? && params[:attendance][:break_end_time] < params[:attendance][:work_start_time] && (params[:attendance][:break_end_time].to_time.hour >= 2 && params[:attendance][:break_end_time].to_time.hour <= 23)
      flash[:danger] = "休憩終了時間よりも出勤時間の方が遅いです。"
      redirect_back(fallback_location: attendance_management)
    elsif params[:attendance][:break_start_time].present? && params[:attendance][:work_end_time].present? && params[:attendance][:break_start_time] > params[:attendance][:work_end_time]
      flash[:danger] = "退勤時間よりも休憩開始時間の方が遅いです。"
      redirect_back(fallback_location: attendance_management)
    elsif params[:attendance][:break_end_time].present? && params[:attendance][:work_end_time].present? && params[:attendance][:break_end_time] > params[:attendance][:work_end_time]
      flash[:danger] = "退勤時間よりも休憩終了時間の方が遅いです。"
      redirect_back(fallback_location: attendance_management)
    else
      @attendance.update_attributes(update_work_time_params)
      flash[:success] = "#{@user.name}の#{l(@attendance.day.to_date, format: :long)}の出退勤情報の編集が完了しました。"
      redirect_back(fallback_location: attendance_management)
    end
  end
  
  #出退勤管理モーダル内の1レコード削除処理
  def destroy
    @attendance.destroy
    flash[:success] = "#{@user.name}の#{l(@attendance.day.to_date, format: :long)}の出退勤情報を削除しました。"
    redirect_back(fallback_location: attendance_management)
  end
  
  #出退勤管理未打刻一覧モーダル
  def attendance_management_notice
  end
  
  ##出退勤管理未打刻一覧モーダル内更新処理
  def update_attendance_management_notice
    #退勤時間が0:00〜2:00までは登録できるようにする
    if params[:work_start_time].present? && params[:work_end_time].present? || params[:break_start_time].present? || params[:break_end_time].present? || params[:work_end_time].to_time.hour >= 0 && params[:work_end_time].to_time.hour <= 2 
      update_work_end_time_params.each do |id, item|
        attendance = Attendance.find(id)
        attendance.update_attributes(work_end_time: item[:work_end_time])
      end
      flash[:success] = "退勤時間の登録に成功しました(退勤時間未入力、出退勤時間が15分以内、出勤時間よりも退勤時間の方が早い場合は登録できていません(0時以降の退勤はこの限りではありません。)"
      redirect_back(fallback_location: attendance_management)
    else
      flash[:danger] = "退勤時間の登録に失敗しました。"
      redirect_back(fallback_location: attendance_management)
    end
  end
  
  #出退勤管理新規作成モーダル
  def new_attendance_management_info
  end
  
  #出退勤管理新規作成モーダル内更新処理
  def create_new_attendance_management_info
    #出退勤新規登録時に、同じ日に同じスタッフで登録されないようにする
    if Attendance.where(day: params[:day], user_id: params[:user_id]).count > 0
      flash[:danger] = "当該日付に同一スタッフが存在しているため、出退勤登録できません。"
      redirect_back(fallback_location: attendance_management)
    elsif params[:day].present? && params[:user_id].present? && params[:work_start_time].blank? && params[:work_end_time].blank? && params[:break_start_time].blank? && params[:break_end_time].blank?
      flash[:danger] = "出退勤情報を入力してください。"
      redirect_back(fallback_location: attendance_management)
    #本日以前の登録はできないようにする
    elsif params[:day].present? && params[:day].to_date <= Date.current
      #出退勤・休憩時間に矛盾がないようにする(出退勤時間が10時〜24時の間の時)
      if params[:work_start_time].present? && params[:work_end_time].present? && params[:work_start_time].to_time.hour >= 10 && params[:work_start_time].to_time.hour <= 24 && params[:work_end_time].to_time.hour >= 10 && params[:work_end_time].to_time.hour <= 24
        if params[:work_start_time].present? && params[:work_end_time].present? && (params[:work_start_time] < params[:work_end_time]) && params[:break_start_time].present? && (params[:break_start_time] > params[:work_start_time]) && (params[:break_start_time] < params[:work_end_time]) && params[:break_end_time].present? && (params[:break_end_time] > params[:work_start_time]) && (params[:break_end_time] < params[:work_end_time])
          @attendance = Attendance.new(day: params[:day], user_id: params[:user_id], work_start_time: params[:work_start_time], break_start_time: params[:break_start_time], break_end_time: params[:break_end_time], work_end_time: params[:work_end_time])
          @attendance.save ? flash[:success] = "出退勤新規登録に成功しました。" : flash[:danger] = "出退勤新規登録に失敗しました。"
          redirect_back(fallback_location: attendance_management)
        #出退勤に矛盾がないようにする
        elsif params[:work_start_time].present? || params[:work_start_time] < params[:break_start_time] || params[:work_start_time] < params[:break_end_time]
          @attendance = Attendance.new(day: params[:day], user_id: params[:user_id], work_start_time: params[:work_start_time], work_end_time: params[:work_end_time], break_start_time: params[:break_start_time], break_end_time: params[:break_end_time])
          @attendance.save ? flash[:success] = "出退勤新規登録に成功しました。" : flash[:danger] = "出退勤新規登録に失敗しました。"
          redirect_back(fallback_location: attendance_management)
        else
          flash[:danger] = "出退勤新規登録に失敗しました。"
          redirect_back(fallback_location: attendance_management)
        end
      else
          @attendance = Attendance.new(day: params[:day], user_id: params[:user_id], work_start_time: params[:work_start_time], break_start_time: params[:break_start_time], break_end_time: params[:break_end_time], work_end_time: params[:work_end_time])
          @attendance.save ? flash[:success] = "出退勤新規登録に成功しました。" : flash[:danger] = "出退勤新規登録に失敗しました。"
          redirect_back(fallback_location: attendance_management)
      end
    else
      flash[:danger] = "出退勤新規登録は本日以前(本日含む)での登録願います。"
      redirect_back(fallback_location: attendance_management)
    end
  end

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
        # IDがusersテーブルに実際に存在するかどうか確認
        @attendance_exist = User.find_by_id(params[:input_id])
        if @attendance_exist
          # 検索で合致した従業員情報を取得
          @attendance_staff = @attendance_exist.authenticate(params[:input_password])
          if @attendance_staff
            # 検索で合致した従業員の勤怠情報を取得
            # 24時以降に退勤を押す場合、朝6時まで退勤を押せるようにする
            if Time.current < (Time.current.beginning_of_day + 6.hour)
              # 1は前日の日付を指定する為
              @attendances = Attendance.where(user_id: @attendance_staff.id).where(day: Date.current - 1)
            else
              # 24時より前に退勤を押す場合
              @attendances = Attendance.where(user_id: @attendance_staff.id).where(day: Date.current)
            end
          else
            # 検索で従業員情報が合致しない場合のメッセージ
            flash.now[:info] = 'IDとパスワードの組み合わせが不正です。'
          end
        else
          # 検索で従業員情報が合致しない場合のメッセージ
          flash[:danger] = 'IDとパスワードの組み合わせが不正です。'
          redirect_to users_attendances_register_url
        end
      elsif ((params[:input_id].present?) && (params[:input_id] != "")) || ((params[:input_password].present?) && (params[:input_password] != ""))
        # 検索で片方のみフォームに入力していた場合のメッセージ
        flash[:danger] = 'IDとパスワード両方入力して下さい。'
        redirect_to users_attendances_register_url
      end
    else
      # 従業員でログインした場合、シフト確認画面に移動する
      redirect_to shifts_current_shifts_user_path(current_user.id)
    end
  end
  
  def create
     # 今日出勤済みかどうか調べる
    if Attendance.find_by(user_id: params[:user_id], day: Date.current)
      flash[:warning] = "本日は出勤済です。"
      redirect_to users_attendances_register_path(current_user)
    else
      # 出勤ボタン押下時にレコードが生成される
      @attendance = Attendance.new(day: Date.current, user_id: params[:user_id], work_start_time: Time.current.change(sec: 0))
      if @attendance.save  
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = "勤怠登録に失敗、もしくは出勤時間が10時前のため出勤不可。"
      end
      redirect_to users_attendances_register_path(current_user)
    end
  end
  
  def update
    # 退勤ボタン押下時、その日のレコードのwork_end_timeをupdateする
    # 24時以降に退勤を押す場合、朝6時まで退勤を押せるようにする
    if Time.current < (Time.current.beginning_of_day + 6.hour)
      # 1は前日の日付を指定する為。朝6時より前の時間に退勤を押す場合
      @attendances = Attendance.where(user_id: params[:user_id]).where(day: Date.current - 1)
    else
      # 24時より前に退勤を押す場合
      @attendances = Attendance.where(user_id: params[:user_id]).where(day: Date.current)
    end
    # 退勤時間が未登録であることを判定します。
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

  private
  
  #給与管理_出退勤情報更新
  def update_work_time_params
    params.require(:attendance).permit(:work_start_time, :break_start_time, :break_end_time, :work_end_time)
  end
  
  #未打刻の退勤時間の更新
  def update_work_end_time_params
    params.require(:attendance).permit(attendances: [:work_end_time])[:attendances]
  end
