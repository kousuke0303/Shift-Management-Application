class AttendanceController < ApplicationController
  belongs_to :user

  before_action :logged_in_user
  before_action :correct_user 
  before_action :admin_user
  
  def salary_management
    @attendance = Attendance.find(params[:id])
  end
end