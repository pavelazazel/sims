class CreateLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :locations do |t|
      t.string :department, null: false
      t.string :room, null: false

      t.timestamps
    end
  end
end
