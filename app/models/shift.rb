class Shift < ApplicationRecord
  belongs_to :user
  include ShiftsHelper
  
  validates :worked_on, presence: true
  validates :user_id, presence: true
  validates :from_staff_msg, length: { maximum: 50 }
  validates :from_admin_msg, length: { maximum: 50 }
  validate :initial_blank
  validate :start_with_end
  validate :correct_start_end_time
  validate :from_staff_msg_with_require_work_time
  
   # 出勤・退勤時間はセットで入力
  def start_with_end
    errors.add(:request_start_time, "を入力してください。") if !request_start_time.present? && request_end_time.present?
    errors.add(:request_end_time, "を入力してください。") if !request_end_time.present? && request_start_time.present?
    errors.add(:start_time, "を入力してください。") if !start_time.present? && end_time.present?
    errors.add(:end_time, "を入力してください。") if !end_time.present? && start_time.present?
  end
  
  # 退勤時間は出勤時間より遅い時間に制限
  def correct_start_end_time
    if request_start_time.present?
      errors.add(:request_start_time, "または、希望終了時間が不正です。") if text_to_time(request_start_time).to_s >= text_to_time(request_end_time).to_s
    end
    if start_time.present?
      errors.add(:start_time, "または、退勤時間が不正です。") if text_to_time(start_time).to_s >= text_to_time(end_time).to_s
    end
  end
  
  # 希望出勤時間、希望退勤時間、出勤時間、退勤時間の初期値は空白
  def initial_blank
    self.request_start_time = "" unless self.request_start_time.present?
    self.request_end_time = "" unless self.request_end_time.present?
    self.start_time = "" unless self.start_time.present?
    self.end_time = "" unless self.end_time.present?
    self.from_staff_msg = "" unless self.from_staff_msg.present?
    self.from_admin_msg = "" unless self.from_admin_msg.present?
  end
  
  # メッセージは勤務時間とセット入力
  def from_staff_msg_with_require_work_time
    if self.from_staff_msg.present? && !self.request_start_time.present? && !self.request_end_time.present?
      errors.add(:request_start_time, "と希望退勤時間を入力してください")
    end
    if self.from_admin_msg.present? && !self.start_time.present? && !self.end_time.present?
      errors.add(:start_time, "と退勤時間を入力してください")
    end
  end
end