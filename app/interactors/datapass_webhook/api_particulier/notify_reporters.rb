class DatapassWebhook::APIParticulier::NotifyReporters < ApplicationInteractor
  def call
    return if %w[submit approve].exclude?(context.event)
    return if groups_to_notify.empty?

    APIParticulier::ReportersMailer.with(groups: groups_to_notify).send(context.event).deliver_later
  end

  private

  def groups_to_notify
    reporters_groups_config.select do |group_name|
      scopes.any? { |scope| scope.start_with?(group_name.to_s) }
    end
  end

  def reporters_groups_config
    Rails.application.credentials.api_particulier_reporters.keys
  end

  def scopes
    context.data['pass']['scopes'].map { |code, bool|
      code if bool
    }.compact
  end
end
