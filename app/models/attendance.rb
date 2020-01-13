class Attendance < ApplicationRecord
  belongs_to :user
  # 出勤ボタン押下時のsaveが無効化される為、永井さんが実装したバリデーションをコメントアウトさせていただきました（白井） 
  validates :salary, presence: true
end
