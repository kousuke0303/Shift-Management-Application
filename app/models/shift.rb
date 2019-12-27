class Shift < ApplicationRecord
  belongs_to :user
  include ShiftsHelper
  
  validates :worked_on, presence: true
  validates :user_id, presence: true
  validates :from_staff_msg, length: { maximum: 50 }
  validates :from_admin_msg, length: { maximum: 50 }
  validate :start_with_end # 出勤・退勤時間はセットで入力
  validate :correct_request_time  # 希望退勤時間は希望出勤時間より遅い時間に制限
  
   # 出勤・退勤時間はセットで入力
  def start_with_end
    errors.add(:request_start_time, "を入力してください。") if !request_start_time.present? && request_end_time.present?
    errors.add(:request_end_time, "を入力してください。") if !request_end_time.present? && request_start_time.present?
    errors.add(:start_time, "を入力してください。") if !start_time.present? && end_time.present?
    errors.add(:end_time, "を入力してください。") if !end_time.present? && start_time.present?
  end
  
  def correct_request_time # 希望退勤時間は希望出勤時間より遅い時間に制限
    if request_start_time.present?
      errors.add(:request_start_time, "または、希望終了時間が不正です。") if text_to_time(request_start_time).to_s >= text_to_time(request_end_time).to_s
    end
  end
end
