# :nocov:
# rubocop:disable Metrics/ClassLength, Metrics/AbcSize, Metrics/MethodLength, Metrics/ParameterLists
module AdminTooling
  class FQFHealthcheckRunner
    attr_reader :external_ids, :editor, :successes, :errors

    def initialize(external_ids:, editor:)
      @external_ids = external_ids
      @editor = editor
      @successes = []
      @errors = []
    end

    def call
      run_healthchecks
      print_summary
    end

    def fix_service_provider_errors
      service_provider_errors = errors.select { |error| error[:failed_checks]&.include?(:service_provider) }

      return if service_provider_errors.empty?

      Rails.logger.debug { "\n#{'=' * 50}" }
      Rails.logger.debug 'Service Provider Fixes'
      Rails.logger.debug '=' * 50
      Rails.logger.debug { "Found #{service_provider_errors.size} authorization request(s) with service_provider errors" }

      service_provider_errors.each do |error|
        Rails.logger.debug { "\n#{error[:external_id]} - #{error[:organization_name]}" }
        Rails.logger.debug { "Current extra_infos: #{error[:authorization_request].extra_infos.inspect}" }
        Rails.logger.debug { "Will update to: { service_provider: { id: \"#{editor[:id]}\", type: \"#{editor[:type]}\", siret: \"#{editor[:siret]}\" } }" }

        Rails.logger.debug 'Update this authorization request? (y/n): '
        response = $stdin.gets.chomp.downcase

        if response == 'y'
          current_extra_infos = error[:authorization_request].extra_infos || {}
          updated_extra_infos = current_extra_infos.merge(
            'service_provider' => {
              'id' => editor[:id],
              'type' => editor[:type],
              'siret' => editor[:siret],
              'admin_message' => "Fixed by jbfeldis on #{Time.now.utc}, cf API-5986"
            }
          )
          error[:authorization_request].update!(extra_infos: updated_extra_infos)
          Rails.logger.debug { "✅ Updated #{error[:external_id]}" }
        else
          Rails.logger.debug { "⏭️  Skipped #{error[:external_id]}" }
        end
      end

      Rails.logger.debug "\nService provider fixes completed!"
    end

    def create_fqf_resources_for_errors
      errors.each do |error|
        create_fqf_resources(error[:authorization_request])
      end
    end

    private

    def run_healthchecks
      external_ids.each do |external_id|
        authorization_request = AuthorizationRequest.find_by(external_id: external_id)

        unless authorization_request
          Rails.logger.debug { "❌ #{external_id}: Authorization request not found" }
          errors << { external_id: external_id, error: 'Authorization request not found' }
          next
        end

        check_authorization_request(authorization_request, external_id)
      end
    end

    def check_authorization_request(authorization_request, external_id)
      org_name = authorization_request.organization&.denomination || 'No organization'
      Rails.logger.debug { "\nChecking #{external_id} - #{org_name}" }

      healthcheck = AdminTooling::FQFHealthcheck.new(authorization_request)
      checks = {}
      all_ok = true

      service_provider_result = healthcheck.service_provider(editor: editor)
      check_result('Service Provider', service_provider_result, checks, :service_provider, all_ok)

      hubee_org_result = healthcheck.hubee_org
      check_result('HubEE Organization', hubee_org_result, checks, :hubee_org, all_ok)

      hubee_sub_result = healthcheck.hubee_sub(editor: editor)
      check_result('HubEE Subscription', hubee_sub_result, checks, :hubee_sub, all_ok)

      fqf_collectivity_result = healthcheck.fqf_collectivity
      check_result('FormulaireQF Collectivity', fqf_collectivity_result, checks, :fqf_collectivity, all_ok)

      all_ok = checks.values.all? { |status| status == :ok }

      store_results(
        external_id,
        org_name,
        authorization_request,
        healthcheck,
        checks,
        all_ok,
        service_provider_result,
        hubee_org_result,
        hubee_sub_result,
        fqf_collectivity_result
      )
    end

    def check_result(name, result, checks, check_key, _all_ok)
      if result[:status] == :ok
        Rails.logger.debug { "  ✅ #{name}" }
        checks[check_key] = :ok
      else
        Rails.logger.debug { "  ❌ #{name} (#{result[:message] || 'not found'})" }
        checks[check_key] = :error
      end
    end

    def store_results(external_id, org_name, authorization_request, healthcheck, checks, all_ok, service_provider_result, hubee_org_result, hubee_sub_result, fqf_collectivity_result)
      results = {
        service_provider: service_provider_result,
        hubee_org: hubee_org_result,
        hubee_sub: hubee_sub_result,
        fqf_collectivity: fqf_collectivity_result
      }

      if all_ok
        Rails.logger.debug { "✅ #{external_id} - #{org_name}: All checks passed" }
        successes << {
          external_id: external_id,
          organization_name: org_name,
          healthcheck: healthcheck,
          results: results
        }
      else
        Rails.logger.debug { "❌ #{external_id} - #{org_name}: Some checks failed" }
        errors << {
          external_id: external_id,
          organization_name: org_name,
          authorization_request: authorization_request,
          healthcheck: healthcheck,
          failed_checks: checks.select { |_, status| status == :error }.keys,
          results: results
        }
      end
    end

    def print_summary
      Rails.logger.debug { "\n#{'=' * 50}" }
      Rails.logger.debug 'Summary'
      Rails.logger.debug '=' * 50
      Rails.logger.debug { "Total: #{external_ids.size}" }
      Rails.logger.debug { "✅ Successes: #{successes.size}" }
      Rails.logger.debug { "❌ Errors: #{errors.size}" }

      return unless errors.any?

      Rails.logger.debug "\nFailed authorization requests:"
      errors.each do |error|
        Rails.logger.debug { "  #{error[:external_id]} - #{error[:organization_name]}" }
        Rails.logger.debug { "    Failed checks: #{error[:failed_checks].join(', ')}" }
      end
    end

    def create_fqf_resources(authorization_request)
      result = DatapassWebhook::CreateFormulaireQFResources.call(authorization_request:)

      if result.success?
        Rails.logger.debug { "✅ Created missing resources for #{authorization_request.external_id}" }
      else
        Rails.logger.debug { "❌ Failed to create resources for #{authorization_request.external_id}: #{result.errors}" }
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength, Metrics/AbcSize, Metrics/MethodLength, Metrics/ParameterLists
