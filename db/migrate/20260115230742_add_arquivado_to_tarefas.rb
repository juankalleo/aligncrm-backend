class AddArquivadoToTarefas < ActiveRecord::Migration[7.1]
  def change
    add_column :tarefas, :arquivado, :boolean, default: false, null: false
    add_column :tarefas, :arquivado_em, :datetime
    add_index :tarefas, :arquivado
  end
end
