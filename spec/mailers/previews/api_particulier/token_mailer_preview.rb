class APIParticulier::TokenMailerPreview < ActionMailer::Preview
  def magic_link
    APIParticulier::TokenMailer.magic_link(magic_link_record, host)
  end

  private

  def magic_link_record
    MagicLink.first
  end

  def host
    'http://entreprise.api.gouv.fr/'
  end
end
