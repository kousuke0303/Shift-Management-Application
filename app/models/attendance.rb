class Attendance < ApplicationRecord
  belongs_to :user
  
   # スタッフ検索と年月日検索できないように制御
  validate :staff_day_both_not_search
  
  def staff_day_both_not_search
    errors.add(:user_id, :day, ":スタッフ検索と年月日検索、両方での検索はできません") if user_id.present? && day.present?
  end
end
