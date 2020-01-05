class Attendance < ApplicationRecord
  belongs_to :user
  
#   scope :day_is, -> day {
#     where(day: day)
#   }
end
