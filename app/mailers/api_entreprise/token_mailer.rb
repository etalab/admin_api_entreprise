class APIEntreprise::TokenMailer < APIEntrepriseMailer
  before_action :attach_logos

  include FriendlyDateHelper
  include ExternalUrlHelper
  include TokenMailersCommons

  %w[
    expiration_notice_90J
    expiration_notice_60J
    expiration_notice_30J
    expiration_notice_15J
    expiration_notice_7J
    expiration_notice_0J
  ].each do |method|
    send('define_method', method) do |args|
      @authorization_request = args[:authorization_request]

      @authorization_request_datapass_url = datapass_authorization_request_url(@authorization_request)
      @expiration_date = Time.at(@authorization_request.token.exp).in_time_zone.strftime('%d/%m/%Y')
      @full_name = @authorization_request.demandeur.full_name
      @intitule = @authorization_request.token.intitule

      mail(to: args[:to], cc: args[:cc], subject: t('.subject')) { |format| format.html }
    end
  end
end
