class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.boolean :admin, default: false
      t.boolean :kitchen, default: false
      t.boolean :hole, default: false
      t.boolean :wash, default: false
      t.integer :hourly_wage
      t.string :remember_digest

      t.timestamps
    end
  end
end
