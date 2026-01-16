class CreateProjetoSolicitacoes < ActiveRecord::Migration[7.0]
  def change
    create_table :projeto_solicitacoes, id: :uuid do |t|
      t.uuid :projeto_id, null: false
      t.uuid :usuario_id, null: false
      t.text :mensagem
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :projeto_solicitacoes, [:projeto_id]
    add_index :projeto_solicitacoes, [:usuario_id]
    add_index :projeto_solicitacoes, [:projeto_id, :usuario_id], unique: true, name: 'index_projeto_solicitacoes_on_projeto_and_usuario'
  end
end
