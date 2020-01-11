class RemoveYearMonthListFromAttendances < ActiveRecord::Migration[5.2]
  def change
    remove_column :attendances, :year, :integer
    remove_column :attendances, :month, :integer
  end
end
