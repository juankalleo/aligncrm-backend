class WorkspaceSerializer < ActiveModel::Serializer
  attributes :id, :nome, :codigo, :proprietario_id, :criado_em, :atualizado_em,
             :storage_usado, :storage_limite, :storage_disponivel, :percentual_uso_storage

  has_many :projetos

  def criado_em
    object.created_at.iso8601
  end

  def atualizado_em
    object.updated_at.iso8601
  end

  def storage_limite
    Workspace::LIMITE_STORAGE
  end

  def storage_disponivel
    object.storage_disponivel
  end

  def percentual_uso_storage
    object.percentual_uso_storage
  end
end
