class CreateFinanceiros < ActiveRecord::Migration[7.1]
  def change
    create_table :financeiros, id: :uuid do |t|
      t.uuid :projeto_id, null: false, index: true
      t.string :categoria, null: false, default: 'outro' # ex: vps, dominio, custo_projeto, outro
      t.string :tipo, null: false, default: 'a_pagar' # a_pagar | a_receber
      t.text :descricao
      t.decimal :valor, precision: 12, scale: 2, null: false, default: 0.0
      t.date :data
      t.boolean :pago, null: false, default: false

      t.timestamps
    end

    add_foreign_key :financeiros, :projetos, column: :projeto_id
  end
end
