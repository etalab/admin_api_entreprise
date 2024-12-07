class APIParticulier::ReportersMailer < APIParticulierMailer
  include ExternalUrlHelper

  skip_before_action :attach_logos

  helper_method :datapass_v2_public_authorization_request_url

  %w[
    submit
    approve
  ].each do |event|
    define_method(event) do
      return if reporters_config.blank?

      groups = params[:groups].map(&:to_sym)

      return if reporter_emails(groups).empty?

      @authorization_request = params[:authorization_request]

      mail(
        bcc: reporter_emails(groups),
        subject: t('.subject')
      )
    end
  end

  private

  def reporter_emails(groups)
    reporters_config.values_at(*groups).flatten
  end

  def reporters_config
    Rails.application.credentials.api_particulier_reporters
  end
end
