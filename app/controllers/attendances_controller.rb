class AttendancesController < ApplicationController
  include AttendancesHelper

  before_action :logged_in_user

  #給与管理
  def salary_management
    #管理者を除いたスタッフを出力
    @staffs = User.where(admin: false)
    #月が10月以降の時と、10月以前で年月日検索を条件分岐
    @attendance = Attendance.find_by(params[:user_id])
    if @attendance.present? && @attendance.day.to_date.month >= 10
      @attendances = Attendance
                     .where(user_id: params[:user_id])
                     .where("day LIKE ?", "#{params['day(1i)']}" << "-" + "#{params['day(2i)']}%")
                     .or(Attendance.where(day: params[:day]))
    else
      @attendances = Attendance
                     .where(user_id: params[:user_id])
                     .where("day LIKE ?", "#{params['day(1i)']}" << "-0" + "#{params['day(2i)']}%")
                     .or(Attendance.where(day: params[:day]))
    end
  end
  
  #給与管理出退勤編集モーダル
  def salary_management_info
    @attendance = Attendance.find(params[:id])
    @user = User.find(@attendance.user_id)
  end
  
  #給与管理モーダル内更新処理
  def update_salary_management_info
    @attendance = Attendance.find(params[:id])
    if params[:attendance][:break_start_time].present? && params[:attendance][:break_end_time].present?
      @attendance.update_attributes(update_work_time_in_break_params)
      flash[:success] = "出退勤情報の編集が完了しました。"
    elsif params[:attendance][:break_start_time].blank? || params[:attendance][:break_end_time].brank?
      @attendance.update_attributes(update_work_time_no_break_params)
      flash[:success] = "出退勤情報の編集が完了しました。"
    end
    redirect_to users_attendances_salary_management_url
  end
  
  #給与管理モーダル内の1レコード削除処理
  def destroy
    @attendance = Attendance.find(params[:id])
    @user = User.find(@attendance.user_id)
    @attendance.destroy
    flash[:success] = "#{@user.name}の#{l(@attendance.day.to_date, format: :long)}の出退勤情報を削除しました。"
    redirect_to users_attendances_salary_management_url
  end
  
  #出退勤管理
  def attendance_management
    #管理者を除いたスタッフを出力
    @staffs = User.where(admin: false)
    @attendance = Attendance.find_by(user_id: params[:user_id])
    #月が10月以降の時と、10月以前で年月日検索を条件分岐
    if @attendance.present? && @attendance.day.to_date.month >= 10
      @attendances = Attendance
                     .where(user_id: params[:user_id])
                     .where("day LIKE ?", "#{params['day(1i)']}" << "-" + "#{params['day(2i)']}%")
                     .or(Attendance.where(day: params[:day]))
    else
      @attendances = Attendance
                     .where(user_id: params[:user_id])
                     .where("day LIKE ?", "#{params['day(1i)']}" << "-0" + "#{params['day(2i)']}%")
                     .or(Attendance.where(day: params[:day]))
    end
  end
  
  #出退勤管理出退勤編集モーダル
  def attendance_management_info
    @attendance = Attendance.find(params[:id])
    @user = User.find(@attendance.user_id)
  end
  
  #出退勤管理モーダル内更新処理
  def update_attendance_management_info
    @attendance = Attendance.find(params[:id])
    if params[:attendance][:break_start_time].present? && params[:attendance][:break_end_time].present?
      @attendance.update_attributes(update_work_time_in_break_params)
      flash[:success] = "出退勤情報の編集が完了しました。"
    elsif params[:attendance][:break_start_time].blank? || params[:attendance][:break_end_time].brank?
      @attendance.update_attributes(update_work_time_no_break_params)
      flash[:success] = "出退勤情報の編集が完了しました。"
    end
    redirect_to users_attendances_attendance_management_url
  end
  
  #出退勤管理モーダル内の1レコード削除処理
  def destroy
    @attendance = Attendance.find(params[:id])
    @user = User.find(@attendance.user_id)
    @attendance.destroy
    flash[:success] = "#{@user.name}の#{l(@attendance.day.to_date, format: :long)}の出退勤情報を削除しました。"
    redirect_to users_attendances_attendance_management_url
  end
  
  #出退勤管理未打刻一覧モーダル
  def attendance_management_notice
  end
  
  ##出退勤管理未打刻一覧モーダル内更新処理
  def update_attendance_management_notice
    update_work_end_time_params.each do |id, item|
      attendance = Attendance.find(id)
      attendance.update_attributes(work_end_time: item[:work_end_time])
    end
    flash[:success] = "退勤時間の登録に成功しました。"
    redirect_to users_attendances_attendance_management_url
  end

  def register
    # 管理者でログインした場合、出退勤登録画面に移動する
    if current_user.admin
      @attendances = Attendance.where(day: Date.current).where.not(work_start_time: nil).where.not(user_id: current_user.id).all.paginate(page: params[:page])
      # 検索があった場合
      if (params[:input_id].present?) && (params[:input_id] != "") && (params[:input_password].present?) && (params[:input_password] != "")
        # 検索で合致した従業員情報を取得
        @attendance_staff = User.find(params[:input_id]).authenticate(params[:input_password])
        if @attendance_staff
          # 検索で合致した従業員の勤怠情報を取得
          @attendances = Attendance.where(user_id: @attendance_staff.id).where(day: Date.current).where.not(work_start_time: nil).where.not(user_id: current_user.id)
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
      # 日本時間に合わせる為、9時間分の秒数を足す→下記ですと、出退勤時間・休憩開始終了時間が９時間プラスされたものとして出力されたため消去(永井)
      # @attendance = Attendance.new(day: Date.today, user_id: current_user.id, work_start_time: Time.current.change(sec: 0) + 32400)
      @attendance = Attendance.new(day: Date.current, user_id: params[:user_id], work_start_time: Time.current)
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

  private
  
  #給与管理_出退勤情報更新(休憩あり)
  def update_work_time_in_break_params
    params.require(:attendance).permit(:work_start_time, :break_start_time, :break_end_time, :work_end_time)
  end
  
  #給与管理_出退勤情報更新(休憩なし)
  def update_work_time_no_break_params
    params.require(:attendance).permit(:work_start_time, :break_start_time, :break_end_time, :work_end_time)
  end
  
  #未打刻の退勤時間の更新
  def update_work_end_time_params
    params.permit(attendances: [:work_end_time])[:attendances]
  end
