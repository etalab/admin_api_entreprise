class AuditNotification < ApplicationRecord
  attr_accessor :request_id_access_logs_input

  validates :authorization_request_external_id, presence: true
  validates :request_id_access_logs, presence: true
  validates :contact_emails, presence: true
  validates :reason, presence: true
  validates :approximate_volume, numericality: { greater_than: 0, allow_nil: true }

  validate :validate_authorization_request_exists
  validate :validate_access_logs_belong_to_authorization_request

  def authorization_request
    @authorization_request ||= AuthorizationRequest.find_by(external_id: authorization_request_external_id)
  end

  def access_logs
    @access_logs ||= AccessLog.where(request_id: request_id_access_logs)
  end

  private

  def validate_authorization_request_exists
    return if authorization_request_external_id.blank?

    return if authorization_request.present?

    errors.add(:authorization_request_external_id, :not_found)
  end

  def validate_access_logs_belong_to_authorization_request
    return if request_id_access_logs.blank? || authorization_request.blank?

    token_ids = authorization_request.tokens.pluck(:id)
    invalid_logs = access_logs.where.not(token_id: token_ids)

    return unless invalid_logs.exists?

    errors.add(:request_id_access_logs, :invalid_association)
  end
end
