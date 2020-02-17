module UsersHelper
  
  # 勤怠レコードから、ユーザー情報を取得
  def find_user_by_attendance(attendance)
    @attendance = User.find(attendance.user_id)
  end
end
