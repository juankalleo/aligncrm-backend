# frozen_string_literal: true

class Financeiro < ApplicationRecord
  belongs_to :projeto, optional: true
  validates :categoria, presence: true
  validates :tipo, presence: true, inclusion: { in: %w[a_pagar a_receber] }
  validates :valor, numericality: { greater_than_or_equal_to: 0 }

  scope :por_projeto, ->(proj_id) { where(projeto_id: proj_id) }
  scope :ordenado, -> { order(data: :desc, created_at: :desc) }
end
