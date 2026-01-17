# frozen_string_literal: true

class CreateVps < ActiveRecord::Migration[7.1]
  def change
    create_table :vps, id: :uuid do |t|
      t.string :nome, null: false
      t.string :login_root, null: false
      t.string :senha_root
      t.string :email_relacionado
      t.integer :storage_gb
      t.datetime :comprado_em
      t.string :comprado_em_local
      t.jsonb :projetos, default: []
      t.uuid :created_by

      t.timestamps
    end

    add_index :vps, :nome
    add_index :vps, :created_by
    add_foreign_key :vps, :usuarios, column: :created_by, primary_key: 'id'
  end
end
