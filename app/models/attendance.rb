class Attendance < ApplicationRecord
  belongs_to :user
  
  validate :work_start_time_cannot_push_less_than_ten_o_clock
  validate :work_end_time_and_break_time_combination_is_wrong
  validate :work_start_time_is_longer_time_work_end_time
  validate :work_start_time_and_work_end_time_into_fifteen_minutes

  def work_start_time_cannot_push_less_than_ten_o_clock
    if work_start_time.present? && work_start_time.hour < 10
      errors.add("10時前の出勤はできません")
    end
  end
  
  def work_end_time_and_break_time_combination_is_wrong
    if work_end_time.present? && break_start_time.present? && break_end_time.present? && break_start_time > work_end_time && break_end_time > work_end_time
      errors.add("退勤時間と休憩時間との組み合わせが不正です。")
    end
  end 
  
  def work_start_time_is_longer_time_work_end_time
    if work_start_time.present? && work_end_time.present? && work_start_time > work_end_time && (work_end_time.hour >= 2 && work_end_time.hour <= 24)
      errors.add("退勤時間よりも出勤時間の方が時間が長いです(ただし退勤時間が0:00〜1:30の場合はこの限りではありません)。")
    end
  end
  
  def work_start_time_and_work_end_time_into_fifteen_minutes
    if work_start_time.present? && work_end_time.present? && work_end_time.hour == work_start_time.hour && work_end_time.min - work_start_time.min <= 15
      errors.add("出勤時間と退勤時間の差分が15分以内の場合、出退勤登録できません。")
    end
  end

  # # 日給の計算を行う
  # before_save :calculate_salary_per_day

  # def calculate_salary_per_day
  #   # 退勤時間が存在時(退勤押下時)に日給の計算を行う
  #   if self.work_end_time.present?
  #     if self.break_end_time.present? && self.break_start_time.present?
  #       # 休憩時間が存在する場合
  #       # 実労働時間の計算
  #       day_work_time = format("%.2f", ((self.work_end_time.floor_to(15.minutes) - (self.break_end_time - self.break_start_time) - self.work_start_time.floor_to(15.minutes)) / 60) / 60.0)
  #     else
  #       # 休憩時間が存在しない場合
  #       # 実労働時間の計算
  #       day_work_time = format("%.2f", ((self.work_end_time.floor_to(15.minutes) - self.work_start_time.floor_to(15.minutes)) / 60) / 60.0)
  #     year = self.work_end_time.year
  #     mon = self.work_end_time.mon
  #     day = self.work_end_time.day
  #     if self.break_end_time.present? && self.break_start_time.present?
  #       # 休憩時間が存在する場合
  #       # 実労働時間の計算
  #       # 勤務終了時間が22時以降かどうか
  #       if self.work_end_time.hour >= 22
  #         # 休憩開始時間が22時以降かどうか
  #         if self.break_start_time <= 22
  #           day_work_time_normal = format("%.2f", ((Time.new(year, mon, day, 13, 00, 00) - (self.break_end_time - self.break_start_time) - self.work_start_time.floor_to(15.minutes)) / 60) / 60.0)
  #           day_work_time_late = format("%.2f", ((self.work_end_time.floor_to(15.minutes) - Time.new(year, mon, day, 13, 00, 00)) / 60) / 60.0)
  #         else
            
  #         end
  #       else
  #         day_work_time = format("%.2f", ((self.work_end_time.floor_to(15.minutes) - (self.break_end_time - self.break_start_time) - self.work_start_time.floor_to(15.minutes)) / 60) / 60.0)
  #       end
  #     else
  #       # 休憩時間が存在しない場合
  #       # 実労働時間の計算
  #       if self.work_end_time.hour >= 22
          
  #       else
  #         day_work_time = format("%.2f", ((self.work_end_time.floor_to(15.minutes) - self.work_start_time.floor_to(15.minutes)) / 60) / 60.0)
  #       end
  #     end
  #     # 日給の計算(実労働時間*そのスタッフの時給)
  #     self.salary = day_work_time.to_f * User.find(self.user_id).hourly_wage
  #   end
  # end
end
