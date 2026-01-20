class AddVencimentoToFinanceiros < ActiveRecord::Migration[7.0]
  def change
    add_column :financeiros, :vencimento, :date
    add_index :financeiros, :vencimento
  end
end
