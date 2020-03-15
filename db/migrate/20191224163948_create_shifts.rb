class CreateShifts < ActiveRecord::Migration[5.1]
  def change
    create_table :shifts do |t|
      t.date :worked_on
      t.date :apply_day
      t.string :request_start_time
      t.string :request_end_time
      t.date :approve_day
      t.string :from_admin_msg
      t.string :from_staff_msg
      t.string :start_time
      t.string :end_time
      t.boolean :release, default: false
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
