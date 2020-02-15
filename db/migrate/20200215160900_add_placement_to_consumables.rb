class AddPlacementToConsumables < ActiveRecord::Migration[5.2]
  def change
    add_column :consumables, :placement, :string
  end
end
