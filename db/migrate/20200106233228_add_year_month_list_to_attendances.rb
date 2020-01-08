class AddYearMonthListToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :year, :integer
    add_column :attendances, :month, :integer
  end
end
