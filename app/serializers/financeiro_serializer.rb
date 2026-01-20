class FinanceiroSerializer < ActiveModel::Serializer
  attributes :id, :projeto_id, :categoria, :tipo, :descricao, :valor, :data, :vencimento, :pago, :created_at, :updated_at
  belongs_to :projeto, serializer: ProjetoSerializer, optional: true

  # Some environments may not have the `vencimento` column applied yet.
  # Return nil if the attribute/method is missing to avoid raising NoMethodError.
  def vencimento
    return nil unless object.respond_to?(:vencimento)
    object.vencimento
  end
end
