class Editor < ApplicationRecord
  has_many :users,
    dependent: :nullify
  has_many :editor_delegations,
    dependent: :destroy
  has_many :editor_tokens,
    dependent: :destroy

  validates :name, presence: true

  scope :delegable, -> { where(delegations_enabled: true) }

  def authorization_requests(api:)
    AuthorizationRequest
      .where(api:)
      .where(demarche: form_uids)
  end
end
