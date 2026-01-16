class WorkspaceInvite < ApplicationRecord
  belongs_to :workspace
  belongs_to :invited_by, class_name: 'Usuario'
  belongs_to :accepted_by, class_name: 'Usuario', optional: true

  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true

  before_validation :ensure_token, on: :create

  def ensure_token
    self.token ||= SecureRandom.urlsafe_base64(24)
  end

  def expired?
    expires_at < Time.current
  end

  def usable?
    !used_at.present? && !expired?
  end

  def mark_used!(usuario = nil)
    update!(used_at: Time.current, accepted_by: usuario)
  end
end
