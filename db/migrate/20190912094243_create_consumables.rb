class CreateConsumables < ActiveRecord::Migration[5.2]
  def change
    create_table :consumables do |t|
      t.string :title, null: false
      t.integer :quantity_in_stock, null: false, default: 0
      t.integer :quantity_in_use, null: false, default: 0
      t.integer :quantity_ready_to_refill, null: false, default: 0
      t.integer :quantity_at_refill, null: false, default: 0

      t.timestamps
    end
  end
end
