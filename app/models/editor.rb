class Editor < ApplicationRecord
  has_many :users,
    dependent: :nullify

  validates :name, presence: true

  def authorization_requests(api:)
    AuthorizationRequest
      .where(api:)
      .where(demarche: form_uids)
  end
end
