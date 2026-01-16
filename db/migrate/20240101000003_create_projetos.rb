# frozen_string_literal: true

class CreateProjetos < ActiveRecord::Migration[7.1]
  def change
    create_table :projetos, id: :uuid do |t|
      t.string :nome, null: false
      t.text :descricao
      t.integer :status, default: 0, null: false
      t.string :cor, default: "#7c6be6"
      t.string :icone
      t.date :data_inicio
      t.date :data_fim
      t.references :proprietario, type: :uuid, null: false, foreign_key: { to_table: :usuarios }

      t.timestamps
    end

    add_index :projetos, :status
    add_index :projetos, :nome
  end
end
