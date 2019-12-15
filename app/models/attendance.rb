class Attendance < ApplicationRecord
  belongs_to :user
  
  validates :worked_on, presence: true
  validates :note, length: { maximum: 50 }
  
  # 出勤時間が存在しない場合、退勤時間は無効
  validate :work_end_time_is_invalid_without_a_work_start_time

  def work_end_time_is_invalid_without_a_work_start_time
    errors.add(:work_start_time, "が必要です") if work_start_time.blank? && work_end_time.present?
  end
end
