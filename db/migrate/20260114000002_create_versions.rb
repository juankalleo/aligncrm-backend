class CreateVersions < ActiveRecord::Migration[7.1]
  def change
    create_table :versions, id: :uuid do |t|
      t.string :item_type, null: false
      t.uuid :item_id
      t.string :event, null: false
      t.string :whodunnit
      t.text :object
      t.jsonb :object_changes
      t.timestamps
    end

    add_index :versions, [:item_type, :item_id]
  end
end
