class CreateConsumableMovements < ActiveRecord::Migration[5.2]
  def change
    create_table :consumable_movements do |t|
      t.references :consumable, foreign_key: true, null: false
      t.references :location, foreign_key: true, null: false

      t.timestamps
    end
  end
end
