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
    
      
    respond_to do |format|
  　   format.all
　    format.csv do |csv|
        send_posts_csv(@attendances)
      end
    end
  end
  
  def send_posts_csv(attendances)
    csv_data = CSV.generate do |csv|
      header = %w(年月日 スタッフ名 出勤時間 退勤時間 休憩開始時間 休憩終了時間 日給)
      csv << header

      attendances.each do |ats|
        values = [l(ats.day, format: :short),
                  ats.user.name, 
                  if ats.work_start_time.nil?
                    ats.work_start_time
                  else
                    l(ats.work_start_time, format: :time)
                  end,
                  if ats.work_end_time.nil?
                    ats.work_end_time
                  else
                    l(ats.work_end_time, format: :time)
                  end,
                  if ats.break_start_time.nil?
                    ats.break_start_time
                  else
                    l(ats.break_start_time, format: :time)
                  end, 
                  if ats.break_end_time.nil?
                    ats.break_end_time
                  else
                    l(ats.break_end_time, format: :time)
                  end, 
                  ats,salary]
        csv << values
      end
    end
    send_data(csv_data, filename: "#{@attendance.user.name}の#{l(@attendance.user.day, format: :short)}の勤怠情報.csv")
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

  def register
    # 管理者でログインした場合、出退勤登録画面に移動する
    if current_user.admin
      @attendance_staff_lists = Attendance.all.paginate(page: params[:page])
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
      # 日本時間に合わせる為、9時間分の秒数を足す→下記ですと、出退勤時間・休憩開始終了時間が９時間プラスされたものとして出力されたため消去(永井)
      # @attendance = Attendance.new(day: Date.today, user_id: current_user.id, work_start_time: Time.current.change(sec: 0) + 32400)
      @attendance = Attendance.new(day: Date.today, user_id: current_user.id, work_start_time: Time.current)
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

  private
  
  #給与管理_出退勤情報更新(休憩あり)
  def update_work_time_in_break_params
    params.require(:attendance).permit(:work_start_time, :break_start_time, :break_end_time, :work_end_time)
  end
  
  #給与管理_出退勤情報更新(休憩なし)
  def update_work_time_no_break_params
    params.require(:attendance).permit(:work_start_time, :break_start_time, :break_end_time, :work_end_time)
  end

