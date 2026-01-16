class AllowNullProjetoOnTarefas < ActiveRecord::Migration[7.1]
  def change
    change_column_null :tarefas, :projeto_id, true
  end
end
