# frozen_string_literal: true

# == Schema Information
#
# Table name: fluxogramas
#
#  id          :uuid             not null, primary key
#  nome        :string           not null
#  descricao   :text
#  projeto_id  :uuid             not null
#  dados       :jsonb            default({})
#  criador_id  :uuid             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Fluxograma < ApplicationRecord
  # Auditoria
  has_paper_trail

  # Associações
  belongs_to :projeto
  belongs_to :criador, class_name: "Usuario"

  # Validações
  validates :nome, presence: true, length: { minimum: 2, maximum: 100 }

  # Scopes
  scope :por_nome, -> { order(:nome) }
  scope :recentes, -> { order(updated_at: :desc) }
end
