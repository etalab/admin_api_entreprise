module ExternalUrlHelper
  def datapass_authorization_request_url(authorization_request)
    "#{datapass_base_url}/api-#{authorization_request.api}/#{authorization_request.external_id}"
  end

  def datapass_reopen_authorization_request_url(authorization_request, prolong_token_wizard = nil)
    url = "#{datapass_base_url}/reopen-enrollment-request-api_#{authorization_request.api}/#{authorization_request.external_id}"

    url += "?highlightedSections=#{highlight_section(prolong_token_wizard).join(',')}" unless prolong_token_wizard.nil?

    url
  end

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

  def datapass_v2_public_authorization_request_url(authorization_request)
    "#{datapass_v2_base_url(authorization_request.api)}/public/demandes/#{authorization_request.public_id}"
  end

  def datapass_v2_base_url(api)
    case Rails.env
    when 'staging'
      "https://staging.api-#{api}.v2.datapass.api.gouv.fr"
    when 'sandbox'
      "https://sandbox.api-#{api}.v2.datapass.api.gouv.fr"
    else
      "https://api-#{api}.v2.datapass.api.gouv.fr"
    end
  end

  private

  def highlight_section(prolong_token_wizard)
    highlight_section = []
    highlight_section << 'description' unless prolong_token_wizard.project_purpose
    highlight_section << 'contact_metier' unless prolong_token_wizard.contact_metier
    highlight_section << 'contact_technique' unless prolong_token_wizard.contact_technique

    highlight_section
  end
end
