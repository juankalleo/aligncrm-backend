class MakeProjetoOptionalInFinanceirosV2 < ActiveRecord::Migration[7.1]
  def change
    change_column_null :financeiros, :projeto_id, true
  end
end
