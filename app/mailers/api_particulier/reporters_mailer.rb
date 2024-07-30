class APIParticulier::ReportersMailer < APIParticulierMailer
  %w[
    submit
    approve
  ].each do |event|
    define_method(event) do
      group = params[:group]

      return if reporters_config[group].blank?

      mail(
        bcc: reporters_config[group],
        subject: t('.subject', group:)
      )
    end
  end

  private

  def reporters_config
    Rails.application.credentials.api_particulier_reporters
  end
end
