class CreateConsumablesNames < ActiveRecord::Migration[5.2]
  def change
    create_table :consumables_names, id: false, primary_key: [:consumable_id, :name_id] do |t|
      t.integer :consumable_id
      t.integer :name_id
    end
  end
end
