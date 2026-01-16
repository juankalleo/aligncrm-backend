# frozen_string_literal: true

# == Schema Information
#
# Table name: links
#
#  id          :uuid             not null, primary key
#  nome        :string           not null
#  url         :string           not null
#  categoria   :integer          default("outro"), not null
#  descricao   :text
#  projeto_id  :uuid
#  criador_id  :uuid             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Link < ApplicationRecord
  # Enums
  enum categoria: {
    github: 0,
    frontend: 1,
    backend: 2,
    ambiente: 3,
    documentacao: 4,
    outro: 5
  }, _prefix: true

  # Associações
  belongs_to :projeto, optional: true
  belongs_to :criador, class_name: "Usuario"

  # Validações
  validates :nome, presence: true, length: { minimum: 2, maximum: 100 }
  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }
  validates :categoria, presence: true

  # Scopes
  scope :por_nome, -> { order(:nome) }
  scope :por_categoria, ->(categoria) { where(categoria: categoria) }
  scope :do_projeto, ->(projeto_id) { where(projeto_id: projeto_id) }
end
