module TokenMailersCommons
  extend ActiveSupport::Concern

  included { before_action :attach_logos }

  include FriendlyDateHelper
  include ExternalUrlHelper

  %w[
    expiration_notice_90J
    expiration_notice_60J
    expiration_notice_30J
    expiration_notice_15J
    expiration_notice_7J
    expiration_notice_0J
  ].each do |method|
    send('define_method', method) do |args|
      token = args[:token]
      @authorization_request = token.authorization_request

      @authorization_request_datapass_url = datapass_authorization_request_url(@authorization_request)
      @expiration_date = Time.at(token.exp).in_time_zone.strftime('%d/%m/%Y')
      @full_name = @authorization_request.demandeur.full_name
      @intitule = token.intitule

      mail(to: token.demandeur.email, subject: t('.subject')) { |format| format.html }
    end
  end

  def magic_link(magic_link, host)
    @magic_link = magic_link
    @host = host

    to = magic_link.email
    subject = t('.subject')

    mail(to:, subject:)
  end
end
