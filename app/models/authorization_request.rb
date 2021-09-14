class AuthorizationRequest < ApplicationRecord
  validates :user, presence: true

  belongs_to :user
  has_one :jwt_api_entreprise, required: false, foreign_key: 'authorization_request_model_id'

  validates :external_id, uniqueness: true, allow_blank: true

  has_many :contacts, dependent: :delete_all

  has_one :contact_technique, -> { where(contact_type: 'tech') }, class_name: 'Contact'
  has_one :contact_metier, -> { where(contact_type: 'admin') }, class_name: 'Contact'

  def editor_name
    editor_config[editor].try(:[], 'name') || editor.try(:humanize)
  end

  private

  def editor_config
    {
      'provigis' => {
        'name' => 'Provigis',
      },
      'achat_solution_com' => {
        'name' => 'Achat-Solution.com',
      },
    }
  end
end
