# frozen_string_literal: true

class Workspace < ApplicationRecord
  # Auditoria
  has_paper_trail

  belongs_to :proprietario, class_name: 'Usuario'
  has_many :projetos, dependent: :nullify

  validates :nome, presence: true, length: { minimum: 2, maximum: 120 }
  validate :limite_workspaces_por_usuario, on: :create

  # Limite de armazenamento: 20GB em bytes
  LIMITE_STORAGE = 20.gigabytes

  scope :por_nome, -> { order(:nome) }

  scope :do_usuario, ->(usuario) {
    left_joins(projetos: :projeto_membros)
      .where('workspaces.proprietario_id = ? OR projeto_membros.usuario_id = ?', usuario.id, usuario.id)
      .distinct
  }

  # Calcula o storage usado somando todos os arquivos dos projetos
  def calcular_storage_usado
    Arquivo.joins(:projeto)
           .where(projetos: { workspace_id: id })
           .sum(:tamanho)
  end

  # Atualiza o storage_usado com o valor real
  def atualizar_storage!
    update_column(:storage_usado, calcular_storage_usado)
  end

  # Verifica se há espaço suficiente para adicionar um arquivo
  def tem_espaco_para?(tamanho_bytes)
    (storage_usado + tamanho_bytes) <= LIMITE_STORAGE
  end

  # Retorna o storage disponível em bytes
  def storage_disponivel
    [LIMITE_STORAGE - storage_usado, 0].max
  end

  # Retorna percentual de uso
  def percentual_uso_storage
    return 0 if LIMITE_STORAGE.zero?
    ((storage_usado.to_f / LIMITE_STORAGE) * 100).round(2)
  end

  private

  def limite_workspaces_por_usuario
    if proprietario && Workspace.where(proprietario_id: proprietario.id).exists?
      errors.add(:base, 'Você já possui um workspace. Cada usuário pode criar apenas um workspace.')
    end
  end
end
