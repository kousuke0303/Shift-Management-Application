module ShiftsHelper
  def text_to_time(text)
    case text
    when "10:00"
      100
    when "10:30"
      105
    when "11:00"
      110
    when "11:30"
      115
    when "12:00"
      120
    when "12:30"
      125
    when "13:00"
      130
    when "13:30"
      135
    when "14:00"
      140
    when "14:30"
      145
    when "15:00"
      150
    when "15:30"
      155
    when "16:00"
      160
    when "16:30"
      165
    when "17:00"
      170
    when "17:30"
      175
    when "18:00"
      180
    when "18:30"
      185
    when "19:00"
      190
    when "19:30"
      195
    when "20:00"
      200
    when "20:30"
      205
    when "21:00"
      210
    when "21:30"
      215
    when "22:00"
      220
    when "22:30"
      225
    when "23:00"
      230
    when "23:30"
      235
    when "ラスト"
      240
    end
  end
end
