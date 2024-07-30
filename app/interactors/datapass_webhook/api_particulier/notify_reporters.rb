class DatapassWebhook::APIParticulier::NotifyReporters < ApplicationInteractor
  def call
    return if %w[submit approve].exclude?(context.event)

    reporters_config.each_key do |group_name|
      next unless scopes.any? { |scope| scope.start_with?("#{group_name}_") }

      APIParticulier::ReportersMailer.with(group: group_name).send(context.event).deliver_later
    end
  end

  private

  def reporters_config
    Rails.application.credentials.api_particulier_reporters
  end

  def scopes
    context.data['pass']['scopes'].map { |code, bool|
      code if bool
    }.compact
  end
end
