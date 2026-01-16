# frozen_string_literal: true

class CreateArquivos < ActiveRecord::Migration[7.1]
  def change
    create_table :arquivos, id: :uuid do |t|
      t.string :nome, null: false
      t.string :nome_original, null: false
      t.integer :tipo, default: 0, null: false
      t.string :mimetype, null: false
      t.bigint :tamanho, null: false
      t.references :projeto, type: :uuid, foreign_key: true
      t.references :uploader, type: :uuid, null: false, foreign_key: { to_table: :usuarios }

      t.datetime :created_at, null: false
    end

    add_index :arquivos, :tipo
    add_index :arquivos, :nome
  end
end
