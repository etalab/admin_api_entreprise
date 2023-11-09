class ScheduleAuthorizationRequestEmailJob < ApplicationJob
  queue_as :default

  attr_reader :authorization_request

  def perform(authorization_request_id, authorization_request_status, template_name, recipients)
    @authorization_request = AuthorizationRequest.find_by(id: authorization_request_id)

    return if authorization_request.blank?
    return if authorization_request_status_changed?(authorization_request_status)

    mailer_klass.public_send(template_name, recipients)
  end

  private

  def mailer_klass
    "#{api_klass}::AuthorizationRequestMailer".constantize
  end

  def api_klass
    "API#{@authorization_request.api.classify}".constantize
  end

  def authorization_request_status_changed?(authorization_request_status)
    authorization_request.status != authorization_request_status &&
      new_status_nomenclature[authorization_request.status] != authorization_request_status
  end

  def new_status_nomenclature
    {
      'pending' => 'draft',
      'modification_pending' => 'changes_requested',
      'sent' => 'submitted',
      'validated' => 'validated',
      'refused' => 'refused'
    }.freeze
  end
end
