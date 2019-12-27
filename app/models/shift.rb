class Shift < ApplicationRecord
  belongs_to :user
  
  validates :worked_on, presence: true
  validates :user_id, presence: true
  validates :from_staff_msg, length: { maximum: 50 }
  validates :from_admin_msg, length: { maximum: 50 }
  validate :start_with_end # 出勤・退勤時間はセットで入力
  
   # 出勤・退勤時間はセットで入力
  def start_with_end
    errors.add(:request_start_time, "を入力してください。") if request_start_time.nil? && request_end_time.present?
    errors.add(:request_end_time, "を入力してください。") if request_end_time.nil? && request_start_time.present?
    errors.add(:start_time, "を入力してください。") if start_time.nil? && end_time.present?
    errors.add(:end_time, "を入力してください。") if end_time.nil? && start_time.present?
  end
end
