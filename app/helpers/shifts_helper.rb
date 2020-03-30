module ShiftsHelper
  def text_to_time(text)
    case text
    when "10:00"
      10
    when "10:30"
      10.5
    when "11:00"
      11
    when "11:30"
      11.5
    when "12:00"
      12
    when "12:30"
      12.5
    when "13:00"
      13
    when "13:30"
      13.5
    when "14:00"
      14
    when "14:30"
      14.5
    when "15:00"
      15
    when "15:30"
      15.5
    when "16:00"
      16
    when "16:30"
      16.5
    when "17:00"
      17
    when "17:30"
      17.5
    when "18:00"
      18
    when "18:30"
      18.5
    when "19:00"
      19
    when "19:30"
      19.5
    when "20:00"
      20
    when "20:30"
      20.5
    when "21:00"
      21
    when "21:30"
      21.5
    when "22:00"
      22
    when "22:30"
      22.5
    when "23:00"
      23
    when "23:30"
      23.5
    when "ラスト"
      "L"
    end
  end
  
  def find_user_by_shift(obj)
    @staff = User.find(obj.user_id)
  end
  
  # ユーザーの、可能なポジションを表示
  def put_position(user)
    if user.kitchen == true && user.hole == false && user.wash == false
      return "キッチン"
    elsif user.kitchen == true && user.hole == false && user.wash == true
      return "キッチン"
    elsif user.kitchen == false && user.hole == true && user.wash == false
      return "ホール"
    elsif user.kitchen == false && user.hole == true && user.wash == true
      return "ホール"
    elsif user.kitchen == true && user.hole == true && user.wash == false
      return "キッチン"
    elsif user.kitchen == true && user.hole == true && user.wash == true
      return "キッチン"
    elsif user.kitchen == false && user.hole == false && user.wash == true
      return "洗い場"
    else
      return "未登録"
    end
  end
  
  # スタッフと日付からシフトレコード検索し、出勤・退勤時間を表示
  def start_and_end_time_of_shift(staff, day)
    shifts = Shift.where(user_id: staff.id, worked_on: day).where("start_time LIKE ?", "%:%")
    @shift = shifts[0]
    "#{text_to_time(@shift.start_time)}-#{text_to_time(@shift.end_time)}" if shifts.count > 0
  end
  
  def empty_shift(staff, day)
    @empty_shift = Shift.where(user_id: staff.id, worked_on: day)[0]
  end
  
  # 前のシフトの@first_dayを定義
  def prev_first_day
    @first_day.day <= 15 ?
    "#{@first_day.prev_month.year}-#{@first_day.prev_month.month}-16".to_date : @first_day.beginning_of_month
  end
  
  # 次のシフトの@first_dayを定義
  def next_first_day
    @first_day.day <= 15 ?
    "#{@first_day.year}-#{@first_day.month}-16".to_date : @first_day.next_month.beginning_of_month
  end
  
  # 現在の最新のシフトか確認
  def current_shifts?
    Date.current.day <= 15 ?
    current_first_day = Date.current.beginning_of_month :
    current_first_day = "#{Date.current.year}-#{Date.current.month}-16".to_date
    return true unless @first_day == current_first_day
  end
  
  # 現在がシフト提出期限内か確認
  def within_submission_deadline?
    Date.current.day.between?(1, 8) || Date.current.day.between?(16, 23) ? true : false
  end
end
