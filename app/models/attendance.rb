class Attendance < ApplicationRecord
  belongs_to :user

  # 日給の計算を行う
  before_save :calculate_salary_per_day

  def calculate_salary_per_day
    # 退勤時間が存在時(退勤押下時)に日給の計算を行う
    if self.work_end_time.present?
      year = self.work_end_time.year
      mon = self.work_end_time.mon
      day = self.work_end_time.day
      if self.break_end_time.present? && self.break_start_time.present?
        # 休憩時間が存在する場合
        # 実労働時間の計算
        # 勤務終了時間が22時以降かどうか
        if self.work_end_time.hour >= 22
          # 休憩開始時間が22時以降かどうか
          if self.break_start_time <= 22
            day_work_time_normal = format("%.2f", ((Time.new(year, mon, day, 13, 00, 00) - (self.break_end_time - self.break_start_time) - self.work_start_time.floor_to(15.minutes)) / 60) / 60.0)
            day_work_time_late = format("%.2f", ((self.work_end_time.floor_to(15.minutes) - Time.new(year, mon, day, 13, 00, 00)) / 60) / 60.0)
          else
            
          end
        else
          day_work_time = format("%.2f", ((self.work_end_time.floor_to(15.minutes) - (self.break_end_time - self.break_start_time) - self.work_start_time.floor_to(15.minutes)) / 60) / 60.0)
        end
      else
        # 休憩時間が存在しない場合
        # 実労働時間の計算
        if self.work_end_time.hour >= 22
          
        else
          day_work_time = format("%.2f", ((self.work_end_time.floor_to(15.minutes) - self.work_start_time.floor_to(15.minutes)) / 60) / 60.0)
        end
      end
      # 日給の計算(実労働時間*そのスタッフの時給)
      self.salary = day_work_time.to_f * User.find(self.user_id).hourly_wage
    end
  end
end
