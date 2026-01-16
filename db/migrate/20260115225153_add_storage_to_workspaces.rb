class AddStorageToWorkspaces < ActiveRecord::Migration[7.1]
  def change
    add_column :workspaces, :storage_usado, :bigint, default: 0, null: false
  end
end
