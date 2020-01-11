class AddDateToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :date, :string
  end
end
