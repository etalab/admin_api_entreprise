class ApplicationMailer < ActionMailer::Base
  layout 'mailer'

  helper :friendly_date

  before_action :extract_host

  protected

  def attach_logos_for(kind)
    attachments.inline['logo-api.png'] = Rails.root.join("app/assets/images/mailers/#{kind}/header-logo-api.png").read
    attachments.inline['logo-dinum.png'] = Rails.root.join('app/assets/images/mailers/header-logo-dinum.png').read
  end

  def valid_host(namespace)
    api = namespace.split('_').last

    case Rails.env
    when 'production'
      "#{api}.api.gouv.fr"
    when 'test', 'development'
      "#{api}.api.localtest.me:3000"
    else
      "#{Rails.env}.#{api}.api.gouv.fr"
    end
  end
end
