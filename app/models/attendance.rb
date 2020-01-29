class Attendance < ApplicationRecord
  belongs_to :user

  # 日給の計算を行う
  before_save :calculate_salary_per_day

  def calculate_salary_per_day
    # 退勤時間が存在時(退勤押下時)に日給の計算を行う
    if self.work_end_time.present?
      if self.break_end_time.present? && self.break_start_time.present?
        # 休憩時間が存在する場合
        # 実労働時間の計算
        day_work_time = format("%.2f", ((self.work_end_time.floor_to(15.minutes) - (self.break_end_time - self.break_start_time) - self.work_start_time.floor_to(15.minutes)) / 60) / 60.0)
      else
        # 休憩時間が存在しない場合
        # 実労働時間の計算
        day_work_time = format("%.2f", ((self.work_end_time.floor_to(15.minutes) - self.work_start_time.floor_to(15.minutes)) / 60) / 60.0)
      end
      # 日給の計算(実労働時間*そのスタッフの時給)
      self.salary = day_work_time.to_f * User.find(self.user_id).hourly_wage
    end
  end
end
