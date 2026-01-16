# frozen_string_literal: true

class CreateUsuarios < ActiveRecord::Migration[7.1]
  def change
    create_table :usuarios, id: :uuid do |t|
      t.string :nome, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.integer :role, default: 1, null: false
      t.boolean :ativo, default: true, null: false
      t.string :avatar_url
      if connection.adapter_name.downcase.include?("sqlite")
        t.json :preferencias, default: {}
      else
        t.jsonb :preferencias, default: {}
      end
      t.datetime :ultimo_login_em

      t.timestamps
    end

    add_index :usuarios, :email, unique: true
    add_index :usuarios, :role
    add_index :usuarios, :ativo
  end
end
