class CreateShifts < ActiveRecord::Migration[5.1]
  def change
    create_table :shifts do |t|
      t.date :worked_on
      t.date :apply_day
      t.text :request_start_time
      t.text :request_end_time
      t.date :approve_day
      t.string :from_admin_msg
      t.string :from_staff_msg
      t.text :start_time
      t.text :end_time
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
