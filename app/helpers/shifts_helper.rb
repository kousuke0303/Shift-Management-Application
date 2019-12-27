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
      24
    end
  end
end
