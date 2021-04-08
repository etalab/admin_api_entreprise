# frozen_string_literal: true

return unless Rails.env.staging?

class StagingEmailInterceptor
  def self.delivering_email(message)
    message.to = [Rails.application.config_for(:mailer_address).fetch(:support)]
  end
end

ActionMailer::Base.register_interceptor(StagingEmailInterceptor)
