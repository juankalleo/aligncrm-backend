# frozen_string_literal: true

class Dominio < ApplicationRecord
  belongs_to :criador, class_name: 'Usuario', foreign_key: 'created_by', optional: true

  validates :nome, presence: true, uniqueness: true
  validates :porta, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  scope :expired, -> { where('expires_at IS NOT NULL AND expires_at < ?', Time.current) }
  scope :expiring_soon, ->(days = 7) { where('expires_at IS NOT NULL AND expires_at <= ?', Time.current + days.days) }

  def expired?
    expires_at.present? && expires_at < Time.current
  end
end
