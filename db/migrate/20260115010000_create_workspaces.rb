class CreateWorkspaces < ActiveRecord::Migration[7.1]
  def change
    create_table :workspaces, id: :uuid do |t|
      t.string :nome, null: false
      t.string :codigo
      t.uuid :proprietario_id, null: false

      t.timestamps
    end

    add_index :workspaces, :codigo
    add_index :workspaces, :proprietario_id
  end
end
