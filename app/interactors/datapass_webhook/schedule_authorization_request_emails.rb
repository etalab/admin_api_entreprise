class DatapassWebhook::ScheduleAuthorizationRequestEmails < ApplicationInteractor
  def call
    (datapass_webhooks_config_for_event[:emails] || []).each do |email_config|
      schedule_email(email_config.stringify_keys)
    end
  end

  private

  def schedule_email(email_config)
    return unless condition_on_authorization_met?(email_config['condition_on_authorization'])

    ScheduleAuthorizationRequestEmailJob.set(wait_until: extract_when_time(email_config['when'])).perform_later(
      context.authorization_request.id,
      context.authorization_request.status,
      build_attributes(email_config)
    )
  end

  def condition_on_authorization_met?(condition_on_authorization)
    return true if condition_on_authorization.nil?

    AuthorizationRequestConditionFacade.new(context.authorization_request).public_send(condition_on_authorization)
  end

  def build_attributes(email_config)
    {
      template_name: email_config['template']
    }.compact.merge(recipients_payload(email_config))
  end

  def recipients_payload(email_config)
    {
      to: recipient_payload(email_config['to'] || default_recipients),
      cc: recipient_payload(email_config['cc'])
    }.compact
  end

  def recipient_payload(user_strings_to_eval)
    return if user_strings_to_eval.blank?

    user_strings_to_eval.map { |user_string_to_eval|
      contact = user_string_to_eval.split('.').reduce(context) do |object, method|
        object.public_send(method)
      end

      next unless contact

      {
        'email' => contact.email,
        'full_name' => contact.full_name
      }
    }.compact
  end

  def default_recipients
    [
      'authorization_request.demandeur'
    ]
  end

  def extract_when_time(when_time)
    Chronic.parse(when_time) || Time.zone.now
  end

  def datapass_webhooks_config_for_event
    datapass_webhooks_config[context.event.to_sym] || { emails: [] }
  end

  def datapass_webhooks_config
    @datapass_webhooks_config ||= Rails.application.config_for("datapass_webhooks_#{context.authorization_request.api}")
  end
end
