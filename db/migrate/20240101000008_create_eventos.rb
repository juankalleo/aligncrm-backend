# frozen_string_literal: true

class CreateEventos < ActiveRecord::Migration[7.1]
  def change
    create_table :eventos, id: :uuid do |t|
      t.string :titulo, null: false
      t.text :descricao
      t.integer :tipo, default: 0, null: false
      t.datetime :data_inicio, null: false
      t.datetime :data_fim
      t.boolean :dia_inteiro, default: false
      t.references :projeto, type: :uuid, foreign_key: true
      t.string :localizacao
      t.string :link_reuniao
      t.string :cor
      t.integer :lembrete
      t.references :criador, type: :uuid, null: false, foreign_key: { to_table: :usuarios }

      t.timestamps
    end

    add_index :eventos, :tipo
    add_index :eventos, :data_inicio

    # Tabela de junção para participantes
    create_table :evento_participantes, id: false do |t|
      t.references :evento, type: :uuid, null: false, foreign_key: true
      t.references :usuario, type: :uuid, null: false, foreign_key: true
    end

    add_index :evento_participantes, [:evento_id, :usuario_id], unique: true
  end
end
