module TokenMailersCommons
  extend ActiveSupport::Concern

  included { before_action :attach_logos }

  include FriendlyDateHelper
  include Rails.application.routes.url_helpers

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

      @prolong_token_url = token_prolong_start_url(token_id: token.id)
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

  def banned(args)
    @token = args[:token]
    @old_token = args[:old_token]
    @authorization_request = @old_token.authorization_request
    @comment = args[:comment]
    @intitule = @authorization_request.intitule
    @blacklisted_at = Time.at(@old_token.blacklisted_at).in_time_zone.strftime('%d/%m/%Y')

    to = args[:email]
    subject = t('.subject')

    mail(to:, subject:)
  end
end
