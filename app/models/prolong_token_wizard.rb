class ProlongTokenWizard < ApplicationRecord
  belongs_to :token

  delegate :prolong!, to: :token
  delegate :authorization_request, to: :token

  enum status: {
    owner: 0,
    project_purpose: 10,
    contacts: 20,
    finished: 100,
    requires_update: 110,
    updates_requested: 120,
    updates_refused: 130,
    prolonged: 200
  }

  validates :owner, presence: true, if: -> { after?(:owner) }
  validates :project_purpose, inclusion: { in: [true, false] }, if: -> { after?(:project_purpose) }
  validates :contact_technique, inclusion: { in: [true, false] }, if: -> { after?(:contacts) }
  validates :contact_metier, inclusion: { in: [true, false] }, if: -> { after?(:contacts) }

  scope :not_finished, -> { where('status IS NULL OR status NOT IN (?)', [ProlongTokenWizard.statuses[:updates_refused], ProlongTokenWizard.statuses[:prolonged]]) }

  def finish!
    return if after?(:finished)

    if should_prolong_token?
      prolong!
    else
      requires_update!
    end
  end

  def new?
    status.nil?
  end

  def renew?
    after?(:updates_refused)
  end

  def after?(kind)
    status.present? && ProlongTokenWizard.statuses[kind] <= ProlongTokenWizard.statuses[status]
  end

  def should_prolong_token?
    owner != 'not_in_charge' &&
      project_purpose &&
      contact_metier &&
      contact_technique
  end

  def prolong!
    update!(status: 'prolonged')
    token.prolong!
  end

  private

  def requires_update!
    update!(status: 'requires_update')
  end
end
