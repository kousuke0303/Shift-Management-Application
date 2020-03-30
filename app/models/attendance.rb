class Attendance < ApplicationRecord
  belongs_to :user
  include AttendancesHelper

  before_save :calculate_salary_per_day
  before_save :delete_calculate_salary_per_day
  validate :work_start_time_errors
  validate :work_start_time_and_work_end_time_errors
  validate :break_time_errors

  #出勤時間のエラー
  def work_start_time_errors
    errors.add(:work_start_time, "10時前の出勤はできません。") if self.work_start_time.present? && self.work_start_time.hour < 10
  end
  
  #出勤時間と退勤時間の組み合わせエラー
  def work_start_time_and_work_end_time_errors
    errors.add(:work_start_time, "よりも退勤時間の方が早いです(ただし退勤時間が0:00〜1:30の場合はこの限りではありません)。") if self.work_start_time.present? && self.work_end_time.present? && (self.work_start_time.strftime("%H:%M") > self.work_end_time.strftime("%H:%M"))  && self.work_end_time.hour >= 2 && self.work_end_time.hour <= 24
    errors.add(:work_start_time, "と退勤時間の差分が15分以内の場合、出退勤登録できません。") if self.work_start_time.present? && self.work_end_time.present? && self.work_end_time.hour == self.work_start_time.hour && (self.work_end_time.min - self.work_start_time.min) <= 15
    errors.add(:work_start_time, "を登録してください。") if !self.work_start_time.present? && self.work_end_time.present?
  end
  
  #休憩時間のエラー
  def break_time_errors
    errors.add(:work_end_time, "は、休憩入以降で登録してください。") if self.work_end_time.present? && self.break_start_time.present? && self.break_start_time > self.work_end_time
    errors.add(:work_end_time, "は、休憩出以降で登録してください。") if self.work_end_time.present? && self.break_end_time.present? && self.break_end_time > self.work_end_time
    errors.add(:break_start_time, "を登録してください。") if !self.break_start_time.present? && self.break_end_time.present?
    errors.add(:break_start_time, "は、出勤時間以降で登録してください。") if self.work_start_time.present? && self.break_start_time.present? && self.break_start_time < self.work_start_time && self.break_start_time.hour >= 10 && self.break_start_time.hour <= 24
    errors.add(:break_end_time, "は、出勤時間以降で登録してください。") if self.work_start_time.present? && self.break_end_time.present? && self.break_end_time < self.work_start_time && self.break_end_time.hour >= 10 && self.break_end_time.hour <= 24
    errors.add(:break_end_time, "を登録してください。") if self.work_end_time.present? && self.break_start_time.present? && !self.break_end_time.present?
    errors.add(:work_start_time, "を登録してください") if !self.work_start_time.present? && self.break_start_time.present?
    errors.add(:break_end_time, "は休憩入以降で登録してください") if self.break_start_time.present? && self.break_end_time.present? && self.break_end_time < self.break_start_time 
  end
  
  # 日給の計算を行う
  def calculate_salary_per_day
    if self.work_start_time.present? && self.work_end_time.present?
      #出勤時間が10時〜21時、退勤時間が０時以降でかつ休憩がある場合、休憩時間を考慮した22時までは通常の日給計算し、退社時間が0時以降は、22時を引いてから24時間分足して計算(1.25倍含む)
      if (self.work_start_time.hour >= 10 && self.work_start_time.hour <= 21) && (self.work_end_time.hour >= 22 && self.work_end_time.hour <= 24) && !(self.work_start_time.strftime("%H:%M") == self.work_end_time.strftime("%H:%M")) && (self.break_start_time.present? && self.break_end_time.present?) 
        non_overtime = (22.0 - ((self.break_end_time.min / 60) - (self.break_start_time.min / 60)) - (self.work_start_time.hour + (self.work_start_time.ceil_to(15.minutes).min / 60.0))).to_f * self.user.hourly_wage.to_f 
        overtime_hourly_wage = ((self.work_end_time.hour + (self.work_end_time.floor_to(15.minutes).min / 60.0)).to_f - 22.0) * self.user.hourly_wage.to_f * 1.25 
        self.salary = non_overtime.to_i + overtime_hourly_wage.to_i 
      #出勤時間が10時〜21時、退勤時間が０時以降でかつ休憩がない場合、22時までは通常の日給計算し、退社時間が0時以降は、22時を引いてから24時間分足して計算(1.25倍含む)
      elsif (self.work_start_time.hour >= 10 && self.work_start_time.hour <= 21) && (self.work_end_time.hour >= 22 && self.work_end_time.hour <= 24) && !(self.work_start_time.strftime("%H:%M") == self.work_end_time.strftime("%H:%M")) 
        non_overtime = (22.0 - (self.work_start_time.hour + (self.work_start_time.ceil_to(15.minutes).min / 60.0))).to_f * self.user.hourly_wage.to_f 
        overtime_hourly_wage = ((self.work_end_time.hour + (self.work_end_time.floor_to(15.minutes).min / 60.0)).to_f  - 22.0) * self.user.hourly_wage.to_f * 1.25 
        self.salary = non_overtime.to_i + overtime_hourly_wage.to_i 
      end 
    
      #出勤時間が10時〜21時、退勤時間が０時以降でかつ休憩がある場合、休憩時間を考慮した22時までは通常の日給計算し、退社時間が0時以降は、22時を引いてから24時間分足して計算(1.25倍含む)
      if (self.work_start_time.hour >= 10 && self.work_start_time.hour <= 21) && (self.work_end_time.hour >= 0 && self.work_end_time.hour <= 9) && !(self.work_start_time.strftime("%H:%M") == self.work_end_time.strftime("%H:%M")) && (self.break_start_time.present? && self.break_end_time.present?) 
        non_overtime_hourly_wage = (22.0 - ((self.break_end_time.min / 60) - (self.break_start_time.min / 60)) - (self.work_start_time.hour + (self.work_start_time.ceil_to(15.minutes).min / 60.0))).to_f * self.user.hourly_wage.to_f 
        tomorrow_overtime_hourly_wage = (self.work_end_time.hour + (self.work_end_time.floor_to(15.minutes).min / 60.0) - 22.0 + 24.0).to_f * self.user.hourly_wage.to_f * 1.25 
        self.salary = non_overtime_hourly_wage.to_i + tomorrow_overtime_hourly_wage.to_i 
      #出勤時間が10時〜21時、退勤時間が０時以降でかつ休憩がない場合、休憩時間を考慮した22時までは通常の日給計算し、退社時間が0時以降は、22時を引いてから24時間分足して計算(1.25倍含む)
      elsif (self.work_start_time.hour >= 10 && self.work_start_time.hour <= 21) && (self.work_end_time.hour >= 0 && self.work_end_time.hour <= 9) && !(self.work_start_time.strftime("%H:%M") == self.work_end_time.strftime("%H:%M")) && !(self.break_start_time.present? && self.break_end_time.present?) 
        non_overtime_hourly_wage = (22.0 - (self.work_start_time.hour + (self.work_start_time.ceil_to(15.minutes).min / 60.0))).to_f * self.user.hourly_wage.to_f 
        tomorrow_overtime_hourly_wage = (self.work_end_time.hour + (self.work_end_time.floor_to(15.minutes).min / 60.0) - 22.0 + 24.0).to_f * self.user.hourly_wage.to_f * 1.25 
        self.salary = non_overtime_hourly_wage.to_i + tomorrow_overtime_hourly_wage.to_i 
      end 
    
      #出勤時間・退勤時間ともに10時〜21時でかつ休憩がある場合、通常の日給計算
      if (self.work_start_time.hour >= 10 && self.work_start_time.hour <= 21) && (self.work_end_time.hour >= 10 && self.work_end_time.hour <= 21) && (self.break_start_time.present? && self.break_end_time.present?) 
        day_hourly_wage = total_time(self.work_start_time.ceil_to(15.minutes), self.break_start_time, self.break_end_time, self.work_end_time.floor_to(15.minutes)).to_f * self.user.hourly_wage.to_f 
        self.salary = day_hourly_wage.to_i
      #出勤時間・退勤時間ともに10時〜21時でかつ休憩がない場合、通常の日給計算
      elsif (self.work_start_time.hour >= 10 && self.work_start_time.hour <= 21) && (self.work_end_time.hour >= 10 && self.work_end_time.hour <= 21) && !(self.break_start_time.present? && self.break_end_time.present?) 
        day_hourly_wage = ((self.work_end_time.hour + (self.work_end_time.floor_to(15.minutes).min / 60.0)).to_f - (self.work_start_time.hour + (self.work_start_time.ceil_to(15.minutes).min / 60.0)).to_f) * self.user.hourly_wage.to_f 
        self.salary = day_hourly_wage.to_i 
      end 
    
      #出勤時間が22時以降で、退社時間が22時以降の場合、22時以降の在社時間を算出
      if (self.work_start_time.hour >= 22 && self.work_start_time.hour <= 24) && (self.work_end_time.hour >= 22 && self.work_end_time.hour <= 24) 
        day_hourly_wage = ((self.work_end_time.hour + (self.work_end_time.floor_to(15.minutes).min / 60.0)).to_f - (self.work_start_time.hour + (self.work_start_time.ceil_to(15.minutes).min / 60.0)).to_f) * self.user.hourly_wage.to_f * 1.25 
        self.salary = day_hourly_wage.to_i 
      end 
    
      #出勤時間が22時以降で、退社時間が0時以降の場合、0時以降の在社時間を算出 
      if (self.work_start_time.hour >= 22 && self.work_start_time.hour <= 24) && (self.work_end_time.hour >= 0 && self.work_end_time.hour <= 9) 
        day_hourly_wage = ((self.work_end_time.hour + (self.work_end_time.floor_to(15.minutes).min / 60.0)).to_f - (self.work_start_time.hour + (self.work_start_time.ceil_to(15.minutes).min / 60.0)).to_f + 24.0) * self.user.hourly_wage.to_f * 1.25 
        self.salary = day_hourly_wage.to_i 
      end 
    
      #出勤時間が0時以降の場合、退社時間が0時以降の場合、0時以降の在社時間を算出
      if (self.work_start_time.hour >= 0 && self.work_start_time.hour <= 9) && (self.work_end_time.hour >= 0 && self.work_end_time.hour <= 9) 
        day_hourly_wage = ((self.work_end_time.hour + (self.work_end_time.floor_to(15.minutes).min / 60.0)).to_f - (self.work_start_time.hour + (self.work_start_time.ceil_to(15.minutes).min / 60.0)).to_f) * self.user.hourly_wage.to_f * 1.25 
        self.salary = day_hourly_wage.to_i 
      end
    end
  end
  
  def delete_calculate_salary_per_day
    if self.work_start_time.present? && self.work_end_time.blank?
      self.salary = nil
    end
  end

  # 日給の計算を行う
  # def calculselfe_salary_per_day
  #   # 退勤時間が存在時(退勤押下時)に日給の計算を行う
  #   if self.work_end_time.present?
  #     if self.break_end_time.present? && self.break_start_time.present?
  #       # 休憩時間が存在する場合
  #       # 実労働時間の計算
  #       day_work_time = formself("%.2f", ((self.work_end_time.floor_to(15.minutes) - (self.break_end_time - self.break_start_time) - self.work_start_time.floor_to(15.minutes)) / 60) / 60.0)
  #     else
  #       # 休憩時間が存在しない場合
  #       # 実労働時間の計算
  #       day_work_time = formself("%.2f", ((self.work_end_time.floor_to(15.minutes) - self.work_start_time.floor_to(15.minutes)) / 60) / 60.0)
  #     year = self.work_end_time.year
  #     mon = self.work_end_time.mon
  #     day = self.work_end_time.day
  #     if self.break_end_time.present? && self.break_start_time.present?
  #       # 休憩時間が存在する場合
  #       # 実労働時間の計算
  #       # 勤務終了時間が22時以降かどうか
  #       if self.work_end_time.hour >= 22
  #         # 休憩開始時間が22時以降かどうか
  #         if self.break_start_time <= 22
  #           day_work_time_normal = formself("%.2f", ((Time.new(year, mon, day, 13, 00, 00) - (self.break_end_time - self.break_start_time) - self.work_start_time.floor_to(15.minutes)) / 60) / 60.0)
  #           day_work_time_lselfe = formself("%.2f", ((self.work_end_time.floor_to(15.minutes) - Time.new(year, mon, day, 13, 00, 00)) / 60) / 60.0)
  #         else
            
  #         end
  #       else
  #         day_work_time = formself("%.2f", ((self.work_end_time.floor_to(15.minutes) - (self.break_end_time - self.break_start_time) - self.work_start_time.floor_to(15.minutes)) / 60) / 60.0)
  #       end
  #     else
  #       # 休憩時間が存在しない場合
  #       # 実労働時間の計算
  #       if self.work_end_time.hour >= 22
          
  #       else
  #         day_work_time = formself("%.2f", ((self.work_end_time.floor_to(15.minutes) - self.work_start_time.floor_to(15.minutes)) / 60) / 60.0)
  #       end
  #     end
  #     # 日給の計算(実労働時間*そのスタッフの時給)
  #     self.salary = day_work_time.to_f * User.find(self.user_id).hourly_wage
  #   end
  # end
end
