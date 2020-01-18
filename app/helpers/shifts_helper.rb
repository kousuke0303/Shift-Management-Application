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
      240
    end
  end
  
  def find_user_by_shift(obj)
    @staff = User.find(obj.user_id)
  end
  
  # ユーザーの、可能なポジションを表示
  def put_position(user)
    if user.kitchen = true && user.hole = false
      return "キッチン"
    elsif user.kitchen = false && user.hole = true
      return "ホール"
    elsif user.kitchen = true && user.hole = true
      return "キッチン/ホール"
    else
      return "洗い場"
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
end
