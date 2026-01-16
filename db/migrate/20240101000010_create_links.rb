# frozen_string_literal: true

class CreateLinks < ActiveRecord::Migration[7.1]
  def change
    create_table :links, id: :uuid do |t|
      t.string :nome, null: false
      t.string :url, null: false
      t.integer :categoria, default: 5, null: false
      t.text :descricao
      t.references :projeto, type: :uuid, foreign_key: true
      t.references :criador, type: :uuid, null: false, foreign_key: { to_table: :usuarios }

      t.timestamps
    end

    add_index :links, :categoria
    add_index :links, :nome
  end
end
