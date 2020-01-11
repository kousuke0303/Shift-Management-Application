class ChangeDateToAttendances < ActiveRecord::Migration[5.2]
  def change
    change_column :attendances, :date, :string
  end
end
