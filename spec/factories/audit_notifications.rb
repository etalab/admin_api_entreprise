FactoryBot.define do
  factory :audit_notification do
    transient do
      authorization_request { create(:authorization_request, :with_demandeur) } # rubocop:disable FactoryBot/FactoryAssociationWithStrategy
    end

    contact_emails do
      [authorization_request.demandeur.email]
    end

    authorization_request_external_id { authorization_request.external_id }
    reason { 'Vous ne renseignez pas correctement le recipient' }

    request_id_access_logs do
      token = authorization_request.active_token || create(:token, authorization_request: authorization_request)

      2.times.map do
        create(:access_log, token: token).request_id
      end
    end
  end
end
