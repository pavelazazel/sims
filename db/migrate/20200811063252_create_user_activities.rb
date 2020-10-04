class CreateUserActivities < ActiveRecord::Migration[5.2]
  def change
    create_table :user_activities do |t|
      t.references :user, foreign_key: true, null: false
      t.string :action, null: false
      t.string :object_type, null: false
      t.integer :object_id, null: false
      t.text :info, null: false

      t.timestamps
    end
  end
end
