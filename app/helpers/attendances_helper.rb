module AttendancesHelper
  #給与合計を算出するために実労働時間を算出するロジック
  def total_time(start_time, start_break_time, finish_break_time, finish_time)
    format("%.2f", (((finish_time - (finish_break_time - start_break_time) - start_time) / 60 ) / 60.0 ))
  end
  
  # def non_overtime(start_time, start_break_time, finish_break_time)
  #   format("%.2f", (((21.0 - (finish_break_time.to_f - start_break_time.to_f) - start_time.to_f) / 60 ) / 60.0 ))
  # end
  
  # def overtime(finish_time)
  #   format("%.2f", (((finish_time.to_f - 22.0) / 60 ) / 60.0 ))
  # end
  
  # def tomorrow_overtime(start_time, start_break_time, finish_break_time, finish_time)
  #   format("%.2f", (((finish_time.to_f - (finish_break_time.to_f - start_break_time.to_f) - start_time.to_f) / 60) / 60.0))
  # end

end