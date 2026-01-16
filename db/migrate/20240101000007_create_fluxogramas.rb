# frozen_string_literal: true

class CreateFluxogramas < ActiveRecord::Migration[7.1]
  def change
    create_table :fluxogramas, id: :uuid do |t|
      t.string :nome, null: false
      t.text :descricao
      t.references :projeto, type: :uuid, null: false, foreign_key: true
      t.jsonb :dados, default: {}
      t.references :criador, type: :uuid, null: false, foreign_key: { to_table: :usuarios }

      t.timestamps
    end

    add_index :fluxogramas, :nome
  end
end
