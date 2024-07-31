class APIParticulier::ReportersMailer < APIParticulierMailer
  skip_before_action :attach_logos

  %w[
    submit
    approve
  ].each do |event|
    define_method(event) do
      groups = params[:groups].map(&:to_sym)

      return if reporter_emails(groups).empty?

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
