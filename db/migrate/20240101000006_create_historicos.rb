# frozen_string_literal: true

class CreateHistoricos < ActiveRecord::Migration[7.1]
  def change
    create_table :historicos, id: :uuid do |t|
      t.integer :acao, null: false
      t.integer :entidade, null: false
      t.uuid :entidade_id, null: false
      t.string :entidade_nome
      t.references :usuario, type: :uuid, null: false, foreign_key: true
      t.jsonb :detalhes, default: {}
      t.string :ip

      t.datetime :created_at, null: false
    end

    add_index :historicos, :acao
    add_index :historicos, :entidade
    add_index :historicos, :entidade_id
    add_index :historicos, :created_at
    add_index :historicos, [:entidade, :entidade_id]
  end
end
