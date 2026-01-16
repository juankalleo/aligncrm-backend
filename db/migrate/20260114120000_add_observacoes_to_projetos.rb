class AddObservacoesToProjetos < ActiveRecord::Migration[7.0]
  def change
    add_column :projetos, :observacoes, :text
  end
end
