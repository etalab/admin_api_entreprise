module ExternalUrlHelper
  def datapass_renewal_url(authorization_request)
    "#{Rails.configuration.token_renewal_url}#{authorization_request.external_id}"
  end

  def datapass_authorization_request_url(authorization_request)
    "#{Rails.configuration.token_authorization_request_url}#{authorization_request.external_id}"
  end
end
