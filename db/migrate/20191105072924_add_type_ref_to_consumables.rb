class AddTypeRefToConsumables < ActiveRecord::Migration[5.2]
  def change
    add_reference :consumables, :consumable_type, null: false
  end
end
