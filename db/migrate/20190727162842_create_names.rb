class CreateNames < ActiveRecord::Migration[5.2]
  def change
    create_table :names do |t|
      t.references :type, foreign_key: true, null: false
      t.references :brand, foreign_key: true, null: false
      t.string :model, null: false

      t.timestamps
    end
  end
end
