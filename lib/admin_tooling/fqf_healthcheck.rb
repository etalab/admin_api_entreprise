# :nocov:
# rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
module AdminTooling
  class FQFHealthcheck
    def initialize(authorization_request)
      @authorization_request = authorization_request
    end

    def service_provider(editor: nil)
      service_provider_data = @authorization_request.extra_infos['service_provider']

      return { status: :not_found, message: 'Not found in extra_infos' } if service_provider_data.blank?

      if editor.present?
        editor_id = editor.is_a?(Hash) ? (editor['id'] || editor[:id]) : editor
        return { status: :error, message: 'Editor mismatch', data: service_provider_data } if service_provider_data['id'] != editor_id
      end

      { status: :ok, data: service_provider_data }
    end

    def hubee_org
      return { status: :error, message: 'Authorization request has no organization' } unless @authorization_request.organization

      organization_data = HubEEAPIClient.new.find_organization(@authorization_request.organization)

      org_status = organization_data['status'] || organization_data[:status]
      return { status: :error, message: "Status is not 'Actif': #{org_status}", data: organization_data } unless org_status&.downcase == 'actif'

      { status: :ok, data: organization_data }
    rescue HubEEAPIClient::NotFound
      { status: :not_found }
    rescue StandardError => e
      { status: :error, message: e.message }
    end

    def hubee_sub(editor: nil)
      return { status: :error, message: 'Authorization request has no organization' } unless @authorization_request.organization

      organization_data = HubEEAPIClient.new.find_organization(@authorization_request.organization)
      subscription_data = HubEEAPIClient.new.find_subscription(
        @authorization_request,
        organization_data,
        'FormulaireQF'
      )

      return { status: :not_found } if subscription_data.blank?

      sub_status = subscription_data['status'] || subscription_data[:status]
      return { status: :error, message: "Status is not 'Actif': #{sub_status}", data: subscription_data } unless sub_status&.downcase == 'actif'

      access_mode = subscription_data['accessMode'] || subscription_data[:accessMode]
      expected_access_mode = editor.present? ? 'API' : 'PORTAIL'

      if access_mode != expected_access_mode
        return {
          status: :error,
          message: "Access mode mismatch: expected '#{expected_access_mode}', got '#{access_mode}'",
          data: subscription_data
        }
      end

      { status: :ok, data: subscription_data }
    rescue HubEEAPIClient::NotFound
      { status: :error, message: 'Organization not found, cannot check subscription' }
    rescue StandardError => e
      { status: :error, message: e.message }
    end

    def fqf_collectivity
      return { status: :error, message: 'Authorization request has no organization' } unless @authorization_request.organization

      collectivity_data = FormulaireQFAPIClient.new.find_collectivity(organization: @authorization_request.organization)

      return { status: :not_found } if collectivity_data.nil?

      { status: :ok, data: collectivity_data }
    rescue StandardError => e
      { status: :error, message: e.message }
    end
  end
end
# rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
