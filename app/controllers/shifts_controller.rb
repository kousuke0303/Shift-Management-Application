class ShiftsController < ApplicationController
  
  before_action :logged_in_user
  before_action :set_user, only:[:apply_next_shifts, :update_next_shifts, :applying_next_shifts, 
                                 :confirm_next_shifts, :current_shifts, :change_release_status, :next_shifts]
  before_action :admin_user, only: [:applying_next_shifts, :confirm_next_shifts, :edit, :update, :add, :add_update, :change_release_status]
  before_action :correct_user, only: [:apply_next_shifts, :update_next_shifts, :applying_next_shifts,
                                      :confirm_next_shifts, :current_shifts, :next_shifts]
  before_action :set_next_shifts_date, only:[:apply_next_shifts, :applying_next_shifts, :change_release_status, :next_shifts]
  before_action :create_next_shifts, only: :apply_next_shifts
  before_action :set_apply_limit, only:[:apply_next_shifts, :applying_next_shifts]
  before_action :set_staff, only: [:edit, :add]
  before_action :set_shift, only: [:edit, :update, :add, :add_update]
  before_action :set_current_shifts_date, only: :current_shifts
  before_action :separate_staffs_by_position, only: [:applying_next_shifts, :current_shifts, :next_shifts]
  before_action :create_current_shifts, only: :current_shifts
  before_action :create_admins_next_shift, only: [:applying_next_shifts, :change_release_status]
  before_action :set_perspnal_shifts, only: [:current_shifts, :next_shifts]
  
  $work_time_breaks = {"10:00": "10:00", "10:30": "10:30","11:00": "11:00", "11:30": "11:30", "12:00": "12:00",
                       "12:30": "12:30", "13:00": "13:00", "13:30": "13:30", "14:00": "14:00", "14:30": "14:30",
                       "15:00": "15:00", "15:30": "15:30", "16:00": "16:00", "16:30": "16:30", "17:00": "17:00",
                       "17:30": "17:30", "18:00": "18:00", "18:30": "18:30", "19:00": "19:00", "19:30": "19:30",
                       "20:00": "20:00", "20:30": "20:30", "21:00": "21:00", "21:30": "21:30", "22:00": "22:00",
                       "22:30": "22:30", "23:00": "23:00", "23:30": "23:30", "ラスト": "ラスト"}
  
  # 承認済シフト編集モーダル
  def edit
  end

  # 承認済シフト編集モーダルのアップデートアクション
  def update
    if params[:remove] && params[:remove].present?
      @shift.update_attributes(start_time: "", end_time: "", from_admin_msg: "") ?
      flash[:success] = "シフトを外しました" : flash[:danger] = "シフトの編集に失敗しました"
    else
      before_start_time = @shift.start_time
      before_end_time = @shift.end_time
      before_from_admin_msg = @shift.from_admin_msg
      if @shift.update_attributes(shift_params)
        unless before_start_time == @shift.start_time && before_end_time == @shift.end_time && before_from_admin_msg == @shift.from_admin_msg
          flash[:success] = "シフトを編集しました。"
        end
      else
        flash[:danger] = "シフトの編集に失敗しました"
      end
    end
    if params[:current]
      redirect_to shifts_current_shifts_user_url(current_user)
    elsif params[:date]
      redirect_to shifts_applying_next_shifts_user_url(current_user, date: params[:date])
    elsif params[:staff]
      redirect_to shifts_applying_next_shifts_user_url(current_user, staff: params[:staff])
    else
      redirect_to shifts_applying_next_shifts_user_url(current_user)
    end
  end
  
  # スタッフの次回のシフト申請ページ
  def apply_next_shifts
  end
  
  # スタッフの次回のシフト申請アクション
  def update_next_shifts
    ActiveRecord::Base.transaction do
      shifts_params.each do |id, item|
        shift = Shift.find(id)
        before_start_time = shift.request_start_time
        before_end_time = shift.request_end_time
        before_from_staff_msg = shift.from_staff_msg
        shift.update_attributes!(item)
        unless before_start_time == shift.request_start_time && before_end_time == shift.request_end_time &&
               shift.from_staff_msg == before_from_staff_msg
          @total_change_count = @total_change_count.to_i + 1
        end
      end
    end
    flash[:success] = "次回のシフトを申請しました" if @total_change_count.to_i > 0
    redirect_to shifts_apply_next_shifts_user_url(@user)
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあった為、申請をキャンセルしました"
    redirect_to shifts_apply_next_shifts_user_url(@user)
  end
  
  # 管理者側の、希望シフトの承認ページ
  def applying_next_shifts
    if params[:date]
      @shifts = Shift.where(worked_on: params[:date]).where("request_start_time LIKE ?", "%:%").
                      where.not("start_time LIKE ?", "%:%")
      @date = params[:date].to_date
    elsif params[:staff]
      @shifts = Shift.where(worked_on: @first_day..@last_day, user_id: params[:staff]).
                      where("request_start_time LIKE ?", "%:%").where.not("start_time LIKE ?", "%:%")
    end
  end
  
  # 管理者側の、希望シフトの承認アクション
  def confirm_next_shifts
    ActiveRecord::Base.transaction do
      shifts_params.each do |id, item|
        shift = Shift.find(id)
        before_start_time = shift.start_time
        before_end_time = shift.end_time
        shift.update_attributes!(item)
        unless before_start_time == shift.start_time && before_end_time == shift.end_time
          @total_change_count = @total_change_count.to_i + 1
        end
      end
    end
    flash[:success] = "シフトに反映しました" if @total_change_count.to_i > 0
    redirect_to shifts_applying_next_shifts_user_url(@user, date: params[:date]) if params[:date]
    redirect_to shifts_applying_next_shifts_user_url(@user, staff: params[:staff]) if params[:staff]
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあった為、申請をキャンセルしました"
    redirect_to shifts_applying_next_shifts_user_url(@user, date: params[:date]) if params[:date]
    redirect_to shifts_applying_next_shifts_user_url(@user, staff: params[:staff]) if params[:staff]
  end
  
  # 管理者の、次回シフト公開状態切り替えアクション
  def change_release_status
    if @admins_shift.release == true
      @admins_shift.update_attributes(release: false) ? flash[:success] = "シフトを非公開にしました" : flash[:danger] = "シフトを非公開に出来ませんでした"
    else
      @admins_shift.update_attributes(release: true) ? flash[:success] = "シフトを公開しました" : flash[:danger] = "シフトを公開出来ませんでした"
    end
    redirect_to shifts_applying_next_shifts_user_url(@user)
  end
  
  # 現在のシフト確認ページ
  def current_shifts
    if Date.current.day <= 15
      @next_first_day = "#{Date.current.year}-#{Date.current.month}-16".to_date
    else
      @next_first_day = Date.current.next_month.beginning_of_month
    end
    @admins_shift = Shift.find_by(user_id: 1, worked_on: @next_first_day)
  end
  
  # 従業員の、次回シフト確認ページ
  def next_shifts
  end
  
  # 新規シフト追加モーダル(シフト希望無い場合)
  def add
  end
  
  # シフト追加アクション
  def add_update
    if @shift.update_attributes(shift_params)
      flash[:success] = "シフトを追加しました" if @shift.start_time.present?
    else
      flash[:danger] = "シフトの追加に失敗しました"
    end
    redirect_to shifts_current_shifts_user_url(current_user)
  end
  
  # beforeフィルター
  
  def set_shift
    @shift = Shift.find(params[:id])
  end
  
  def set_staff
    @staff = User.find(params[:user_id])
  end

  # 申請を求めるシフトの、日付を定義
  def set_next_shifts_date
    if Date.current.day <= 15
      @first_day = "#{Date.current.year}-#{Date.current.month}-16".to_date
      @last_day = @first_day.end_of_month
    else
      @first_day = Date.current.next_month.beginning_of_month
      @last_day = "#{@first_day.year}-#{@first_day.month}-15".to_date
    end
    @next_shifts = [*@first_day..@last_day]
  end
  
  # 申請を求めるシフトの、レコードを自動生成
  def create_next_shifts
    @shifts = @user.shifts.where(worked_on: @first_day..@last_day).order(:worked_on)
    unless @next_shifts.count == @shifts.count
      ActiveRecord::Base.transaction do
        @next_shifts.each { |day| @user.shifts.create!(worked_on: day) }
      end
      @shifts = @user.shifts.where(worked_on: @first_day..@last_day).order(:worked_on)
    end
  rescue ActiveRecord::RecordInvalid 
    flash[:danger] = "ページ情報の取得に失敗しました、再アクセスしてください"
    redirect_to root_url
  end
  
  # シフトの募集・作成期間を定義
  def set_apply_limit
    if Date.current.day <= 15
      @start_apply_day = Date.current.beginning_of_month
      @end_apply_day = @start_apply_day.since(7.days)
      @start_create_day = @start_apply_day.since(8.days)
      @end_create_day = @start_apply_day.since(14.days)
    else
      @start_apply_day = Date.current.beginning_of_month.since(15.days)
      @end_apply_day = @start_apply_day.since(7.days)
      @start_create_day = @start_apply_day.since(8.days)
      @end_create_day = @start_apply_day.end_of_month
    end
  end
  
  # 現在のシフトの期間を定義
  def set_current_shifts_date
    if params[:date]
      @first_day = params[:date].to_date
    else
      Date.current.day <= 15 ?
      @first_day = Date.current.beginning_of_month : @first_day = "#{Date.current.year}-#{Date.current.month}-16".to_date
    end
    @first_day.day <= 15 ?
    @last_day = "#{@first_day.year}-#{@first_day.month}-15".to_date : @last_day = @first_day.end_of_month
    @current_shifts = [*@first_day..@last_day]
  end
  
  # 現在のシフトレコードを自動生成
  def create_current_shifts
    ActiveRecord::Base.transaction do
      @staffs.each do |staff|
        unless @current_shifts.count == staff.shifts.where(worked_on: @first_day..@last_day).count
          @current_shifts.each { |day| staff.shifts.create!(worked_on: day) }
        end
      end
    end
  rescue ActiveRecord::RecordInvalid 
    flash[:danger] = "ページ情報の取得に失敗しました、再アクセスしてください"
    redirect_to root_url
  end
  
  # スタッフをポジション毎に変数に代入
  def separate_staffs_by_position
    @staffs = User.where(admin: false)
    @kitchen_staffs = User.where(admin: false, kitchen: true)
    @hole_staffs = User.where(admin: false, kitchen: false, hole: true)
    @wash_staffs = User.where(admin: false, kitchen: false, hole: false, wash: true)
    @newcomer_staffs = User.where(admin: false, kitchen: false, hole: false, wash: false)
  end
  
  def create_admins_next_shift
    unless @admins_shift = Shift.find_by(user_id: @user.id, worked_on: @first_day)
      unless Shift.create(user_id: @user.id, worked_on: @first_day, release: false)
        flash[:danger] = "ページ情報の取得に失敗しました、再アクセスしてください"
        redirect_to root_url
      end
    end
    @admins_shift = Shift.find_by(user_id: @user.id, worked_on: @first_day)
  end
  
  # 個人の反映済シフト取得
  def set_perspnal_shifts
    @shifts = @user.shifts.where(worked_on: @first_day..@last_day).where("start_time LIKE ?", "%:%").order(:worked_on)
  end
  
  private
    def shifts_params
      params.require(:user).permit(shifts: [:request_start_time, :request_end_time, :from_staff_msg, :apply_day,
                                            :start_time, :end_time, :from_admin_msg])[:shifts]
    end
    
    def shift_params
      params.require(:shift).permit(:start_time, :end_time, :from_admin_msg)
    end
end