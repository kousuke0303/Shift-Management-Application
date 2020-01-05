# class UserAttendanceSearchForm
#   include ActiveModel::Model
  
#   attr_accessor :name, :day
  
#   def search
#     rel = User.all
#     rel = rel.where(name: name) if name.present?
#     rel = rel.joins(:attendance).eager_load(:attendance).where("attendances.day = ?", attendances.params[:day]).uniq if day.present?
#     rel
#   end
# end