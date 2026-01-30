class Editor < ApplicationRecord
  belongs_to :oauth_application, optional: true

  has_many :users, dependent: :nullify
  has_many :editor_delegations, dependent: :destroy
  has_many :delegated_authorization_requests,
    through: :editor_delegations,
    source: :authorization_request

  validates :name, presence: true

  def authorization_requests(api:)
    AuthorizationRequest
      .where(api:)
      .where(demarche: form_uids)
  end

  def generate_oauth_credentials!
    return oauth_application if oauth_application.present?

    oauth_app = OAuthApplication.create!(name: "OAuth - #{name}", owner: self)
    update!(oauth_application: oauth_app)
    oauth_app
  end

  def can_access_authorization_request?(authorization_request)
    editor_delegations.active.exists?(authorization_request:)
  end
end
