class CreateWorkspaceInvites < ActiveRecord::Migration[7.1]
  def change
    create_table :workspace_invites, id: :uuid do |t|
      t.string :token, null: false
      t.references :workspace, type: :uuid, null: false, foreign_key: true
      t.references :invited_by, type: :uuid, null: false, foreign_key: { to_table: :usuarios }
      t.references :accepted_by, type: :uuid, foreign_key: { to_table: :usuarios }
      t.datetime :expires_at, null: false
      t.datetime :used_at

      t.timestamps
    end

    add_index :workspace_invites, :token, unique: true
  end
end
