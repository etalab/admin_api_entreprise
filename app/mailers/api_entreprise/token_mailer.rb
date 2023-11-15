class APIEntreprise::TokenMailer < APIEntrepriseMailer
  before_action :attach_logos

  include FriendlyDateHelper
  include ExternalUrlHelper
  include TokenMailersCommons

  %w[
    expiration_notice_J-90
    expiration_notice_J-60
    expiration_notice_J-30
    expiration_notice_J-15
    expiration_notice_J-7
    expiration_notice_J-0_expired
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
