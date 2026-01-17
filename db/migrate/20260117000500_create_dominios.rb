# frozen_string_literal: true

class CreateDominios < ActiveRecord::Migration[7.1]
  def change
    create_table :dominios, id: :uuid do |t|
      t.string :nome, null: false
      t.integer :porta
      t.string :nginx_server
      t.datetime :expires_at
      t.boolean :notified, default: false, null: false
      t.uuid :created_by

      t.timestamps
    end

    add_index :dominios, :nome, unique: true
    add_index :dominios, :expires_at
    add_index :dominios, :created_by
    add_foreign_key :dominios, :usuarios, column: :created_by, primary_key: "id"
  end
end
