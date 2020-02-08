class AttendancesController < ApplicationController
  include AttendancesHelper

  before_action :logged_in_user
  before_action :set_attendance, only: [:salary_management_info, :update_salary_management_info, :destroy, :attendance_management_info, :update_attendance_management_info, :attendance_management_notice, :update_attendance_management_notice] 
  before_action :set_attendance_user_id, only: [:salary_management_info, :update_salary_management_info, :destroy, :attendance_management_info, :update_attendance_management_info]
  before_action :set_staff, only:[:salary_management, :attendance_management, :new_attendance_management_info]

  #給与管理
  def salary_management
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
  end
  
  #給与管理モーダル内更新処理
  def update_salary_management_info
    if params[:attendance]['work_start_time(4i)'].present? && params[:attendance]['work_start_time(4i)'].to_i < 10
      flash[:danger] = "勤務時間が10時以前は出勤登録できません。"
      redirect_back(fallback_location: salary_management)
    elsif (params[:attendance]['work_start_time(4i)'].to_i > params[:attendance]['break_start_time(4i)'].to_i) || (params[:attendance]['work_start_time(4i)'].to_i > params[:attendance]['break_end_time(4i)'].to_i) || (params[:attendance]['work_end_time(4i)'].to_i < params[:attendance]['break_start_time(4i)'].to_i) || (params[:attendance]['work_end_time(4i)'].to_i < params[:attendance]['break_end_time(4i)'].to_i)
      flash[:danger] = "出退勤時間と休憩時間の組み合わせが不正です。"
      redirect_back(fallback_location: salary_management)
    elsif (params[:attendance]['work_start_time(4i)'].to_i >= 10 && params[:attendance]['work_start_time(4i)'].to_i <= 24 && params[:attendance]['break_start_time(4i)'].to_i >= 0 && params[:attendance]['break_start_time(4i)'].to_i <= 9) && (params[:attendance]['work_start_time(4i)'].to_i >= 10 && params[:attendance]['work_start_time(4i)'].to_i <= 24 && params[:attendance]['break_end_time(4i)'].to_i >= 0 && params[:attendance]['break_end_time(4i)'].to_i <= 9) && (params[:attendance]['work_end_time(4i)'].to_i >= 10 && params[:attendance]['work_end_time(4i)'].to_i <= 24 && params[:attendance]['break_start_time(4i)'].to_i >= 0 && params[:attendance]['break_start_time(4i)'].to_i <= 9) && (params[:attendance]['work_end_time(4i)'].to_i >= 10 && params[:attendance]['work_end_time(4i)'].to_i <= 24 && params[:attendance]['break_end_time(4i)'].to_i >= 0 && params[:attendance]['break_end_time(4i)'].to_i <= 9)
      flash[:danger] = "出退勤時間と休憩時間の組み合わせが不正です。"
      redirect_back(fallback_location: salary_management)
    elsif (params[:attendance]['break_start_time(4i)'].to_i == params[:attendance]['break_end_time(4i)'].to_i) && (params[:attendance]['break_start_time(5i)'].to_i > params[:attendance]['break_end_time(5i)'].to_i)
      flash[:danger] = "出退勤時間と休憩時間の組み合わせが不正です。"
      redirect_back(fallback_location: salary_management)
    elsif (params[:attendance]['work_start_time(4i)'].to_i == params[:attendance]['break_start_time(4i)'].to_i) && (params[:attendance]['work_start_time(5i)'].to_i > params[:attendance]['break_start_time(5i)'].to_i)
      flash[:danger] = "出退勤時間と休憩時間の組み合わせが不正です。"
      redirect_back(fallback_location: salary_management)
    elsif (params[:attendance]['work_start_time(4i)'].to_i == params[:attendance]['break_end_time(4i)'].to_i) && (params[:attendance]['work_start_time(5i)'].to_i > params[:attendance]['break_end_time(5i)'].to_i)
      flash[:danger] = "出退勤時間と休憩時間の組み合わせが不正です。"
      redirect_back(fallback_location: salary_management)
    elsif (params[:attendance]['work_end_time(4i)'].to_i == params[:attendance]['break_start_time(4i)'].to_i) && (params[:attendance]['work_end_time(5i)'].to_i < params[:attendance]['break_start_time(5i)'].to_i)
      flash[:danger] = "出退勤時間と休憩時間の組み合わせが不正です。"
      redirect_back(fallback_location: salary_management)
    elsif (params[:attendance]['work_end_time(4i)'].to_i == params[:attendance]['break_end_time(4i)'].to_i) && (params[:attendance]['work_end_time(5i)'].to_i < params[:attendance]['break_end_time(5i)'].to_i)
      flash[:danger] = "出退勤時間と休憩時間の組み合わせが不正です。"
      redirect_back(fallback_location: salary_management)
    elsif (params[:attendance]['work_start_time(4i)'].to_i > params[:attendance]['work_end_time(4i)'].to_i) && !(params[:attendance]['work_end_time(4i)'].to_i >= 0 && params[:attendance]['work_end_time(4i)'].to_i <= 1)
      flash[:danger] = "出勤時間と退勤時間の組み合わせが不正です。"
      redirect_back(fallback_location: salary_management)
    elsif (params[:attendance]['work_start_time(4i)'].to_i == params[:attendance]['work_end_time(4i)'].to_i) && (params[:attendance]['work_start_time(5i)'].to_i > params[:attendance]['work_end_time(5i)'].to_i)
      flash[:danger] = "出勤時間と退勤時間の組み合わせが不正です。"
      redirect_back(fallback_location: salary_management)
    elsif params[:attendance]['break_start_time(4i)'].to_i > params[:attendance]['break_end_time(4i)'].to_i
      flash[:danger] = "休憩開始時間と休憩終了時間の組み合わせが不正です。"
      redirect_back(fallback_location: salary_management)
    elsif (params[:attendance]['break_start_time(4i)'].to_i >= 0 && params[:attendance]['break_start_time(4i)'].to_i <= 2) && (params[:attendance]['break_end_time(4i)'].to_i >= 10 && params[:attendance]['break_end_time(4i)'].to_i <= 24)
      flash[:danger] = "休憩開始時間と休憩終了時間の組み合わせが不正です。"
      redirect_back(fallback_location: salary_management)
    elsif params[:attendance]['work_start_time(4i)'].present? && params[:attendance]['work_start_time(4i)'].to_i >= 10 && params[:attendance][:break_start_time].present? && params[:attendance][:break_end_time].present?
      @attendance.update_attributes(update_work_time_params)
      flash[:success] = "#{@user.name}の#{l(@attendance.day.to_date, format: :long)}の出退勤情報の編集が完了しました。"
      redirect_back(fallback_location: salary_management)
    elsif params[:attendance]['work_start_time(4i)'].present? && params[:attendance]['work_start_time(4i)'].to_i >= 10 || params[:attendance][:break_start_time].blank? || params[:attendance][:break_end_time].brank?
      @attendance.update_attributes(update_work_time_params)
      flash[:success] = "#{@user.name}の#{l(@attendance.day.to_date, format: :long)}の出退勤情報の編集が完了しました。"
      redirect_back(fallback_location: salary_management)
    end
  end
  
  #給与管理モーダル内の1レコード削除処理
  def destroy
    @attendance.destroy
    flash[:success] = "#{@user.name}の#{l(@attendance.day.to_date, format: :long)}の出退勤情報を削除しました。"
    redirect_back(fallback_location: salary_management)
  end
  
  #出退勤管理
  def attendance_management
    @attendance = Attendance.find_by(user_id: params[:user_id])
    @shift = Shift.find(params[:id])
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
  end
  
  #出退勤管理モーダル内更新処理
  def update_attendance_management_info
    if (params[:attendance]['break_start_time(4i)'].to_i == params[:attendance]['work_end_time(4i)'].to_i) && (params[:attendance]['work_end_time(5i)'].to_i - params[:attendance]['break_start_time(5i)'].to_i <= 15) && (params[:attendance]['break_end_time(4i)'].to_i == params[:attendance]['work_end_time(4i)'].to_i) && (params[:attendance]['work_end_time(5i)'].to_i - params[:attendance]['break_end_time(5i)'].to_i <= 15)
      flash[:danger] = "退勤時間の休憩時間の差が15分以内のため、出退勤編集できません"
      redirect_back(fallback_location: attendance_management)
    elsif params[:attendance]['work_start_time(4i)'].present? && params[:attendance]['work_start_time(4i)'].to_i < 10
      flash[:danger] = "勤務時間が10時以前は出勤登録できません"
      redirect_back(fallback_location: attendance_management)
    elsif params[:attendance]['break_start_time(4i)'].present? && params[:attendance]['break_start_time(5i)'].present? && params[:attendance]['break_end_time(4i)'].present? && params[:attendance]['break_end_time(5i)']
      if (params[:attendance]['work_start_time(4i)'].to_i > params[:attendance]['break_start_time(4i)'].to_i) || (params[:attendance]['work_start_time(4i)'].to_i > params[:attendance]['break_end_time(4i)'].to_i) || (params[:attendance]['work_end_time(4i)'].to_i < params[:attendance]['break_start_time(4i)'].to_i) || (params[:attendance]['work_end_time(4i)'].to_i < params[:attendance]['break_end_time(4i)'].to_i)
        flash[:danger] = "出退勤時間と休憩時間の組み合わせが不正です。"
        redirect_back(fallback_location: attendance_management)
      elsif (params[:attendance]['work_start_time(4i)'].to_i >= 10 && params[:attendance]['work_start_time(4i)'].to_i <= 24 && params[:attendance]['break_start_time(4i)'].to_i >= 0 && params[:attendance]['break_start_time(4i)'].to_i <= 9) && (params[:attendance]['work_start_time(4i)'].to_i >= 10 && params[:attendance]['work_start_time(4i)'].to_i <= 24 && params[:attendance]['break_end_time(4i)'].to_i >= 0 && params[:attendance]['break_end_time(4i)'].to_i <= 9) && (params[:attendance]['work_end_time(4i)'].to_i >= 10 && params[:attendance]['work_end_time(4i)'].to_i <= 24 && params[:attendance]['break_start_time(4i)'].to_i >= 0 && params[:attendance]['break_start_time(4i)'].to_i <= 9) && (params[:attendance]['work_end_time(4i)'].to_i >= 10 && params[:attendance]['work_end_time(4i)'].to_i <= 24 && params[:attendance]['break_end_time(4i)'].to_i >= 0 && params[:attendance]['break_end_time(4i)'].to_i <= 9)
        flash[:danger] = "出退勤時間と休憩時間の組み合わせが不正です。"
        redirect_back(fallback_location: attendance_management)
      elsif (params[:attendance]['break_start_time(4i)'].to_i == params[:attendance]['break_end_time(4i)'].to_i) && (params[:attendance]['break_start_time(5i)'].to_i > params[:attendance]['break_end_time(5i)'].to_i)
        flash[:danger] = "出退勤時間と休憩時間の組み合わせが不正です。"
        redirect_back(fallback_location: attendance_management)
      elsif (params[:attendance]['work_start_time(4i)'].to_i == params[:attendance]['break_start_time(4i)'].to_i) && (params[:attendance]['work_start_time(5i)'].to_i > params[:attendance]['break_start_time(5i)'].to_i)
        flash[:danger] = "出退勤時間と休憩時間の組み合わせが不正です。"
        redirect_back(fallback_location: attendance_management)
      elsif (params[:attendance]['work_start_time(4i)'].to_i == params[:attendance]['break_end_time(4i)'].to_i) && (params[:attendance]['work_start_time(5i)'].to_i > params[:attendance]['break_end_time(5i)'].to_i)
        flash[:danger] = "出退勤時間と休憩時間の組み合わせが不正です。"
        redirect_back(fallback_location: attendance_management)
      elsif (params[:attendance]['work_end_time(4i)'].to_i == params[:attendance]['break_start_time(4i)'].to_i) && (params[:attendance]['work_end_time(5i)'].to_i < params[:attendance]['break_start_time(5i)'].to_i)
        flash[:danger] = "出退勤時間と休憩時間の組み合わせが不正です。"
        redirect_back(fallback_location: attendance_management)
      elsif (params[:attendance]['work_end_time(4i)'].to_i == params[:attendance]['break_end_time(4i)'].to_i) && (params[:attendance]['work_end_time(5i)'].to_i < params[:attendance]['break_end_time(5i)'].to_i)
        flash[:danger] = "出退勤時間と休憩時間の組み合わせが不正です。"
        redirect_back(fallback_location: attendance_management)
      elsif (params[:attendance]['work_start_time(4i)'].to_i > params[:attendance]['work_end_time(4i)'].to_i) && !(params[:attendance]['work_end_time(4i)'].to_i >= 0 && params[:attendance]['work_end_time(4i)'].to_i <= 1)
        flash[:danger] = "出勤時間と退勤時間の組み合わせが不正です。"
        redirect_back(fallback_location: attendance_management)
      elsif (params[:attendance]['work_start_time(4i)'].to_i == params[:attendance]['work_end_time(4i)'].to_i) && (params[:attendance]['work_start_time(5i)'].to_i > params[:attendance]['work_end_time(5i)'].to_i)
        flash[:danger] = "出勤時間と退勤時間の組み合わせが不正です。"
        redirect_back(fallback_location: attendance_management)
      elsif params[:attendance]['break_start_time(4i)'].to_i > params[:attendance]['break_end_time(4i)'].to_i
        flash[:danger] = "休憩開始時間と休憩終了時間の組み合わせが不正です。"
        redirect_back(fallback_location: attendance_management)
      elsif (params[:attendance]['break_start_time(4i)'].to_i >= 0 && params[:attendance]['break_start_time(4i)'].to_i <= 2) && (params[:attendance]['break_end_time(4i)'].to_i >= 10 && params[:attendance]['break_end_time(4i)'].to_i <= 24)
        flash[:danger] = "休憩開始時間と休憩終了時間の組み合わせが不正です。"
        redirect_back(fallback_location: attendance_management)
      end
    elsif params[:attendance]['work_start_time(4i)'].present? && params[:attendance]['work_start_time(4i)'].to_i >= 10
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
    update_work_end_time_params.each do |id, item|
      attendance = Attendance.find(id)
      attendance.update_attributes!(work_end_time: item[:work_end_time])
    end
    flash[:success] = "退勤時間の登録に成功しました(退勤時間を入力していなければ登録されていません。"
    redirect_to users_attendances_attendance_management_url
  end
  
  #出退勤管理新規作成モーダル
  def new_attendance_management_info
  end
  
  #出退勤管理新規作成モーダル内更新処理
  def create_new_attendance_management_info
    if Attendance.where(day: params[:day], user_id: params[:user_id]).count > 0
      flash[:danger] = "同一日に同一ユーザーが存在しているため、出退勤登録できません。"
      redirect_to users_attendances_attendance_management_url
    elsif params[:work_start_time].present? && (params[:work_start_time] < params[:work_end_time]) && params[:break_start_time].present? && (params[:break_start_time] > params[:work_start_time]) && (params[:break_start_time] < params[:work_end_time]) && params[:break_end_time].present? && (params[:break_end_time] > params[:work_start_time]) && (params[:break_end_time] < params[:work_end_time]) && params[:work_end_time].present?
      @attendance = Attendance.new(day: params[:day], user_id: params[:user_id], work_start_time: params[:work_start_time], break_start_time: params[:break_start_time], break_end_time: params[:break_end_time], work_end_time: params[:work_end_time])
      @attendance.save ? flash[:success] = "出退勤新規登録に成功しました。" : flash[:danger] = "出退勤新規登録に失敗しました。"
      redirect_to users_attendances_attendance_management_url
    elsif params[:work_start_time].present? && (params[:work_start_time] < params[:work_end_time]) && params[:break_start_time].blank? && params[:break_end_time].blank? && params[:work_end_time].present?
      @attendance = Attendance.new(day: params[:day], user_id: params[:user_id], work_start_time: params[:work_start_time], work_end_time: params[:work_end_time])
      @attendance.save ? flash[:success] = "出退勤新規登録に成功しました。" : flash[:danger] = "出退勤新規登録に失敗しました。"
      redirect_to users_attendances_attendance_management_url
    elsif params[:day].blank? || params[:user_id].blank? || params[:work_start_time].blank? || params[:work_end_time].blank? || params[:break_start_time].blank? || params[:break_end_time].blank?
      flash[:warning] = "もう一度入力してください。"
      redirect_to users_attendances_attendance_management_url
    else
      flash[:warning] = "出勤時間が10時前、または出退勤時間と休憩時間の組み合わせが不正の場合、出退勤登録されていません。"
      redirect_to users_attendances_attendance_management_url
    end
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
          @attendances = Attendance.where(user_id: @attendance_staff.id).where(day: Date.current).where.not(work_start_time: nil).where.not(user_id: current_user.id).all.paginate(page: params[:page])
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
  
  #給与管理_出退勤情報更新
  def update_work_time_params
    params.require(:attendance).permit(:work_start_time, :break_start_time, :break_end_time, :work_end_time)
  end
  
  #出退勤新規登録(休憩あり)
  def update_work_time_in break_params
    params.require(:attendance).permit(:work_start_time, :break_start_time, :break_end_time, :work_end_time)
  end
  
  #出退勤新規登録(休憩なし)
  def update_work_time_no_break_params
    params.require(:attendance).permit(:work_start_time, :work_end_time)
  end
  
  #未打刻の退勤時間の更新
  def update_work_end_time_params
    params.require(:attendance).permit(attendances: [:work_end_time])[:attendances]
  end
