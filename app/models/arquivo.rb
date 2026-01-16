# frozen_string_literal: true

# == Schema Information
#
# Table name: arquivos
#
#  id            :uuid             not null, primary key
#  nome          :string           not null
#  nome_original :string           not null
#  tipo          :integer          default("documento"), not null
#  mimetype      :string           not null
#  tamanho       :bigint           not null
#  projeto_id    :uuid
#  uploader_id   :uuid             not null
#  created_at    :datetime         not null
#
class Arquivo < ApplicationRecord
  # Enums
  enum tipo: {
    documento: 0,
    imagem: 1,
    video: 2,
    audio: 3,
    outro: 4
  }, _prefix: true

  # Associações
  belongs_to :projeto
  belongs_to :uploader, class_name: "Usuario"

  # Active Storage
  has_one_attached :file

  # Validações
  validates :nome, presence: true
  validates :nome_original, presence: true
  validates :mimetype, presence: true
  validates :tamanho, presence: true, numericality: { greater_than: 0 }

  # Scopes
  scope :por_nome, -> { order(:nome) }
  scope :recentes, -> { order(created_at: :desc) }
  scope :do_projeto, ->(projeto_id) { where(projeto_id: projeto_id) }

  # Callbacks
  before_validation :detectar_tipo, on: :create

  # Métodos
  def url
    Rails.application.routes.url_helpers.rails_blob_url(file) if file.attached?
  end

  def tamanho_formatado
    return "0 B" if tamanho.nil? || tamanho.zero?
    
    units = ["B", "KB", "MB", "GB"]
    exp = (Math.log(tamanho) / Math.log(1024)).to_i
    exp = units.length - 1 if exp > units.length - 1
    
    "%.2f %s" % [tamanho.to_f / 1024**exp, units[exp]]
  end

  private

  def detectar_tipo
    return if mimetype.blank?
    
    self.tipo = case mimetype
                when /^image\//
                  :imagem
                when /^video\//
                  :video
                when /^audio\//
                  :audio
                when /pdf|document|spreadsheet|presentation/
                  :documento
                else
                  :outro
                end
  end
end
