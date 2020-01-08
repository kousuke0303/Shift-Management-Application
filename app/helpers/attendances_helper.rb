module AttendancesHelper
  #給与合計を算出するために実労働時間を算出するロジック
  def total_time(start_time, start_break_time, finish_break_time, finish_time)
    format("%.2f", (((finish_time - (finish_break_time - start_break_time) - start_time) / 60 ) / 60.0 ))
  end
end
