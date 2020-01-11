class Attendance < ApplicationRecord
  belongs_to :user
  
  # validates :salary, presence: true
end
