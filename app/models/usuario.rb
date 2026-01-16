# frozen_string_literal: true

# == Schema Information
#
# Table name: usuarios
#
#  id                   :uuid             not null, primary key
#  nome                 :string           not null
#  email                :string           not null
#  password_digest      :string           not null
#  role                 :integer          default("user"), not null
#  ativo                :boolean          default(TRUE), not null
#  avatar_url           :string
#  preferencias         :jsonb            default({})
#  ultimo_login_em      :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
class Usuario < ApplicationRecord
  # Auditoria
  has_paper_trail

  # Autenticação
  has_secure_password

  # Enums
  enum role: {
    viewer: 0,
    user: 1,
    manager: 2,
    admin: 3
  }

  # Associações
  has_many :projetos_criados, class_name: "Projeto", foreign_key: "proprietario_id", dependent: :nullify
  has_many :projeto_membros, dependent: :destroy
  has_many :projetos, through: :projeto_membros
  has_many :tarefas_atribuidas, class_name: "Tarefa", foreign_key: "responsavel_id", dependent: :nullify
  has_many :tarefas_criadas, class_name: "Tarefa", foreign_key: "criador_id", dependent: :nullify
  has_many :registros_historico, class_name: "Historico", dependent: :destroy
  has_many :arquivos, foreign_key: "uploader_id", dependent: :nullify
  has_many :links_criados, class_name: "Link", foreign_key: "criador_id", dependent: :nullify
  has_many :fluxogramas_criados, class_name: "Fluxograma", foreign_key: "criador_id", dependent: :nullify
  has_many :eventos_criados, class_name: "Evento", foreign_key: "criador_id", dependent: :nullify

  # Active Storage
  has_one_attached :avatar

  # Validações
  validates :nome, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || password.present? }
  validates :role, presence: true

  # Callbacks
  before_save :downcase_email

  # Scopes
  scope :ativos, -> { where(ativo: true) }
  scope :admins, -> { where(role: :admin) }
  scope :por_nome, -> { order(:nome) }
  scope :do_workspace, ->(workspace) {
    joins(projetos: :workspace)
      .where('workspaces.id = ?', workspace.id)
      .distinct
  }

  # Métodos
  def nome_completo
    nome
  end

  def iniciais
    nome.split.map(&:first).join.upcase[0..1]
  end

  def pode_gerenciar_usuarios?
    admin? || manager?
  end

  def atualizar_ultimo_login!
    update_column(:ultimo_login_em, Time.current)
  end

  private

  def downcase_email
    self.email = email.downcase
  end
end
