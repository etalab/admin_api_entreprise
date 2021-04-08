# frozen_string_literal: true

return if Rails.env.test? || Rails.env.production?

options = {
  deliver_emails_to: Rails.application.config_for(:mailer_address).fetch(:domains),
  forward_emails_to: Rails.application.config_for(:mailer_address).fetch(:catcher)
}

interceptor = MailInterceptor::Interceptor.new(**options)
ActionMailer::Base.register_interceptor(interceptor)
