# frozen_string_literal: true

# == Schema Information
#
# Table name: tarefas
#
#  id              :uuid             not null, primary key
#  titulo          :string           not null
#  descricao       :text
#  status          :integer          default("backlog"), not null
#  prioridade      :integer          default("media"), not null
#  projeto_id      :uuid             not null
#  responsavel_id  :uuid
#  criador_id      :uuid             not null
#  prazo           :datetime
#  estimativa_horas :integer
#  tags            :string           default([]), array: true
#  ordem           :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class Tarefa < ApplicationRecord
  # Auditoria
  has_paper_trail

  # Enums
  enum status: {
    backlog: 0,
    todo: 1,
    em_progresso: 2,
    revisao: 3,
    concluida: 4,
    cancelada: 5
  }, _prefix: true

  enum prioridade: {
    baixa: 0,
    media: 1,
    alta: 2,
    urgente: 3
  }, _prefix: true

  # Associações
  belongs_to :projeto, optional: true
  belongs_to :responsavel, class_name: "Usuario", optional: true
  belongs_to :criador, class_name: "Usuario"

  # Validações
  validates :titulo, presence: true, length: { minimum: 2, maximum: 200 }
  validates :status, presence: true
  validates :prioridade, presence: true
  validates :ordem, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Scopes
  scope :por_status, ->(status) { where(status: status) }
  scope :por_prioridade, ->(prioridade) { where(prioridade: prioridade) }
  scope :ordenadas, -> { order(:ordem) }
  scope :com_prazo_proximo, -> { where("prazo <= ?", 3.days.from_now).where.not(prazo: nil) }
  scope :atrasadas, -> { where("prazo < ?", Time.current).where.not(status: [:concluida, :cancelada]) }
  scope :do_responsavel, ->(usuario) { where(responsavel: usuario) }
  scope :nao_arquivadas, -> { where(arquivado: false) }
  scope :arquivadas, -> { where(arquivado: true) }
  scope :concluidas_antigas, -> { 
    where(status: :concluida, arquivado: false)
      .where('updated_at < ?', 5.days.ago) 
  }

  # Callbacks
  before_create :definir_ordem_inicial

  # Métodos
  def atrasada?
    prazo.present? && prazo < Time.current && !status_concluida? && !status_cancelada?
  end

  def dias_para_prazo
    return nil unless prazo.present?
    (prazo.to_date - Date.current).to_i
  end

  def atribuir_responsavel!(usuario)
    update!(responsavel: usuario)
  end

  def remover_responsavel!
    update!(responsavel: nil)
  end

  def mover_para!(novo_status, nova_ordem)
    update!(status: novo_status, ordem: nova_ordem)
    reordenar_outras_tarefas
  end

  def arquivar!
    update!(arquivado: true, arquivado_em: Time.current)
  end

  private

  def definir_ordem_inicial
    if projeto.present?
      max_ordem = projeto.tarefas.where(status: status).maximum(:ordem) || -1
      self.ordem = max_ordem + 1
    else
      self.ordem = 0
    end
  end

  def reordenar_outras_tarefas
    # Reordenar tarefas do mesmo status e projeto
    return unless projeto.present?

    projeto.tarefas
           .where(status: status)
           .where.not(id: id)
           .where("ordem >= ?", ordem)
           .order(:ordem)
           .each_with_index do |tarefa, index|
      tarefa.update_column(:ordem, ordem + index + 1)
    end
  end
end
