class AddOrdemToProjetos < ActiveRecord::Migration[7.1]
  def change
    add_column :projetos, :ordem, :integer, default: 0, null: false
    add_index :projetos, :ordem
  end
end
