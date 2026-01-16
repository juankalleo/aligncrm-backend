# frozen_string_literal: true

class CreateTarefas < ActiveRecord::Migration[7.1]
  def change
    create_table :tarefas, id: :uuid do |t|
      t.string :titulo, null: false
      t.text :descricao
      t.integer :status, default: 0, null: false
      t.integer :prioridade, default: 1, null: false
      t.references :projeto, type: :uuid, null: false, foreign_key: true
      t.references :responsavel, type: :uuid, foreign_key: { to_table: :usuarios }
      t.references :criador, type: :uuid, null: false, foreign_key: { to_table: :usuarios }
      t.datetime :prazo
      t.integer :estimativa_horas
      t.string :tags, array: true, default: []
      t.integer :ordem, default: 0, null: false

      t.timestamps
    end

    add_index :tarefas, :status
    add_index :tarefas, :prioridade
    add_index :tarefas, :prazo
    add_index :tarefas, [:projeto_id, :status, :ordem]
  end
end
