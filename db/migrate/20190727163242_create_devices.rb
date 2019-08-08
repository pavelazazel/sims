class CreateDevices < ActiveRecord::Migration[5.2]
  def change
    create_table :devices do |t|
      t.references :name, foreign_key: true, null: false
      t.string :inventory_number, null: false
      t.string :serial_number, null: false
      t.references :location, foreign_key: true, null: false
      t.text :comment, null: false, default: ""

      t.timestamps
    end
  end
end
