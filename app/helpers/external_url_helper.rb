module ExternalUrlHelper
  def datapass_renewal_url(authorization_request)
    "#{datapass_base_url}/copy-authorization-request/#{authorization_request.external_id}"
  end

  def datapass_authorization_request_url(authorization_request)
    "#{datapass_base_url}/api-#{authorization_request.api}/#{authorization_request.external_id}"
  end

  private

  def datapass_base_url
    case Rails.env
    when 'staging'
      'https://staging.datapass.api.gouv.fr'
    when 'sandbox', 'test', 'development'
      'https://sandbox.datapass.api.gouv.fr'
    else
      'https://datapass.api.gouv.fr'
    end
  end
end
