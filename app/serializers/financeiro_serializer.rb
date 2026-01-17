class FinanceiroSerializer < ActiveModel::Serializer
  attributes :id, :projeto_id, :categoria, :tipo, :descricao, :valor, :data, :vencimento, :pago, :created_at, :updated_at

  belongs_to :projeto, serializer: ProjetoSerializer, optional: true
end
