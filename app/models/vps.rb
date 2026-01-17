# frozen_string_literal: true

class Vps < ApplicationRecord
  belongs_to :criador, class_name: 'Usuario', foreign_key: 'created_by', optional: true

  validates :nome, presence: true
  validates :login_root, presence: true
  validates :storage_gb, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  # projetos stored as JSON array of hashes { id: ..., nome: ... }
  def projetos_list
    projetos || []
  end

  def has_password?
    senha_root.present?
  end
end
