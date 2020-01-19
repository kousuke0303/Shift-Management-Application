class Attendance < ApplicationRecord
  belongs_to :user
  # 出勤ボタン押下時のsaveが無効化される為、永井さんが実装したバリデーションをコメントアウトさせていただきました（白井） 
  # validates :salary, presence: true
  # # 退勤時間が存在したら日給の計算を行う
  # after_update :calculate_salary_per_day
  
  # # 日給の計算を行う
  # def calculate_salary_per_day
  #   if self.work_end_time.present?
  #     # 実労働時間の計算
  #     day_work_time = total_time(self.work_start_time.floor_to(15.minutes), self.break_start_time, self.break_end_time.floor_to(15.minutes), self.work_end_time)
  #     # 日給の計算(実労働時間*そのスタッフの時給)
  #     self.salary = day_work_time * User.find(current_user.id).hourly_wage
  #   end
  # end
  
  before_save :calculate_salary_per_day
  
  def calculate_salary_per_day
    if self.work_end_time.present?
      # 実労働時間の計算
      day_work_time = format("%.2f", ((self.work_end_time.floor_to(15.minutes) - (self.break_end_time - self.break_start_time) - self.work_start_time.floor_to(15.minutes)) / 60) / 60.0)
      # 日給の計算(実労働時間*そのスタッフの時給)
      self.salary = day_work_time.to_f * User.find(self.user_id).hourly_wage
      debugger
    end
  end
end
