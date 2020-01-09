class ShiftsController < ApplicationController
  
  before_action :set_user, only:[:apply_next_shifts, :update_next_shifts, :applying_next_shifts, :confirm_next_shifts]
  before_action :set_next_shifts_date, only:[:apply_next_shifts, :applying_next_shifts]
  before_action :create_next_shifts, only: :apply_next_shifts
  before_action :set_apply_limit, only:[:apply_next_shifts, :applying_next_shifts]
  before_action :set_shift, only: [:edit, :update]
  
  def new
    @shift = Shift.new
  end
  
  def create
  end
  
  def edit
    find_user_by_shift(@shift) # シフトの所有スタッフを定義
  end

  def update
    if params[:remove] && params[:remove].present?
      if @shift.update_attributes(start_time: "", end_time: "")
        flash[:success] = "シフトを外しました。"
      else
        flash[:danger] = "シフトの編集に失敗しました。"
      end
    elsif
      if @shift.update_attributes(shift_params)
        flash[:success] = "シフトを編集しました。"
      else
        flash[:danger] = "シフトの編集に失敗しました。"
      end
    end
    if params[:date]
      redirect_to shifts_applying_next_shifts_user_path(current_user, date: params[:date])
    elsif params[:staff]
      redirect_to shifts_applying_next_shifts_user_path(current_user, staff: params[:staff])
    else
      redirect_to shifts_applying_next_shifts_user_path(current_user)
    end
  end
  
  def apply_next_shifts
  end
  
  def update_next_shifts
    ActiveRecord::Base.transaction do
      shifts_params.each do |id, item|
        shift = Shift.find(id)
        shift.update_attributes!(item)
      end
    end
    flash[:success] = "次回のシフトを申請しました。"
    redirect_to shifts_apply_next_shifts_user_path(@user)
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあった為、申請をキャンセルしました。"
    redirect_to shifts_apply_next_shifts_user_path(@user)
  end
  
  def applying_next_shifts
    @kitchen_staff = User.where(admin: false, kitchen: true)
    @hole_staff = User.where(admin: false, kitchen: false, hole: true)
    @staffs = User.where(admin: false)
    if params[:date]
      @shifts = Shift.where(worked_on: params[:date]).where("request_start_time LIKE ?", "%:%").
                      where.not("start_time LIKE ?", "%:%")
      @date = params[:date].to_date
    elsif params[:staff]
      @shifts = Shift.where(worked_on: @first_day..@last_day, user_id: params[:staff]).
                      where("request_start_time LIKE ?", "%:%").where.not("start_time LIKE ?", "%:%")
    end
  end
  
  def confirm_next_shifts
    ActiveRecord::Base.transaction do
      shifts_params.each do |id, item|
        shift = Shift.find(id)
        shift.update_attributes!(item)
      end
    end
    flash[:success] = "シフトに反映しました。"
    redirect_to shifts_applying_next_shifts_user_path(@user, date: params[:date]) if params[:date]
    redirect_to shifts_applying_next_shifts_user_path(@user, staff: params[:staff]) if params[:staff]
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあった為、申請をキャンセルしました。"
    redirect_to shifts_applying_next_shifts_user_path(@user)
  end
  
  # beforeフィルター
  
  def set_shift
    @shift = Shift.find(params[:id])
  end

  # 申請を求めるシフトの、日付を定義
  def set_next_shifts_date
    if Date.current.day <= 15
      @first_day = "#{Date.current.year}-#{Date.current.month}-16".to_date
      @last_day = @first_day.end_of_month
    else
      @first_day = Date.current.next_month.beginning_of_month
      @last_day = @first_day.since(14.days)
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
    flash[:danger] = "ページ情報の取得に失敗しました、再アクセスしてください。"
    redirect_to root_url
  end
  
  # シフトの募集・作成期間を定義
  def set_apply_limit
    if Date.current.day <= 15
      @start_apply_day = Date.current.beginning_of_month
      @end_apply_day = Date.current.beginning_of_month.since(7.days)
      @start_create_day = @start_apply_day.since(8.days)
      @end_create_day = @start_apply_day.since(14.days)
    else
      @start_apply_day = Date.current.beginning_of_month.since(15.days)
      @end_apply_day = @start_apply_day.since(7.days)
      @start_create_day = @start_apply_day.since(8.days)
      @end_create_day = @start_apply_day.end_of_month
    end
  end
  
  private
    def shifts_params
      params.require(:user).permit(shifts: [:request_start_time, :request_end_time, :from_staff_msg, :apply_day,
                                            :start_time, :end_time])[:shifts]
    end
    
    def shift_params
      params.require(:shift).permit(:start_time, :end_time, :from_admin_msg)
    end
end
