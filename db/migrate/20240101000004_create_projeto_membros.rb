# frozen_string_literal: true

class CreateProjetoMembros < ActiveRecord::Migration[7.1]
  def change
    create_table :projeto_membros, id: :uuid do |t|
      t.references :projeto, type: :uuid, null: false, foreign_key: true
      t.references :usuario, type: :uuid, null: false, foreign_key: true
      t.integer :papel, default: 0, null: false

      t.timestamps
    end

    add_index :projeto_membros, [:projeto_id, :usuario_id], unique: true
  end
end
