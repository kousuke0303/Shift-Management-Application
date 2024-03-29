class CreateAttendances < ActiveRecord::Migration[5.1]
  def change
    create_table :attendances do |t|
      t.string :day
      t.datetime :work_start_time
      t.datetime :break_start_time
      t.datetime :break_end_time
      t.datetime :work_end_time
      t.integer :salary
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
