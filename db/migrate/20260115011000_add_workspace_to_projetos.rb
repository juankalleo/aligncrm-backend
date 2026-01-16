class AddWorkspaceToProjetos < ActiveRecord::Migration[7.1]
  def change
    add_reference :projetos, :workspace, type: :uuid, foreign_key: true, null: true
  end
end
