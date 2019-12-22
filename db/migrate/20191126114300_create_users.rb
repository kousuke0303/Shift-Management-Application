class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.boolean :leader
      t.boolean :kitchen
      t.boolean :hole
      t.boolean :admin, default: false
      t.string :remember_digest

      t.timestamps
    end
  end
end
