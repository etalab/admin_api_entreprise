# frozen_string_literal: true

require 'rails_helper'

RSpec.describe APIEntreprise::AuditMailer do
  describe '#notify' do
    subject(:mail) do
      described_class.with(
        audit_notification:
      ).notify
    end

    let(:audit_notification) { build(:audit_notification, authorization_request:, reason:, request_id_access_logs:) }
    let(:reason) { 'Usage non conforme détecté dans vos appels API' }
    let(:authorization_request) { create(:authorization_request, :with_all_contacts, siret: '13002526500013') }
    let!(:organization) { create(:organization, :with_insee_payload, siret: '13002526500013') }
    let(:access_log) do
      create(:access_log, token: create(:token, authorization_request: authorization_request))
    end
    let(:request_id_access_logs) do
      [access_log.request_id]
    end

    it 'has the correct subject' do
      expect(mail.subject).to eq("🔍 Anomalie détectée sur votre habilitation DataPass n°#{authorization_request.external_id}")
    end

    describe 'contact emails' do
      context 'when authorization request has all contacts' do
        it 'sends email to demandeur, contact_technique, and contact_metier' do
          expect(mail.to).to contain_exactly(
            authorization_request.demandeur.email,
            authorization_request.contact_technique.email,
            authorization_request.contact_metier.email
          )
        end
      end

      context 'when authorization request has only demandeur' do
        let(:authorization_request) { create(:authorization_request, :with_demandeur) }

        it 'sends email only to demandeur' do
          expect(mail.to).to contain_exactly(authorization_request.demandeur.email)
        end
      end
    end

    it 'displays logs section header' do
      expect(mail.html_part.decoded).to include('📜 Détails des appels non conformes')

      expect(mail.html_part.decoded).to include(access_log.request_id)
      expect(mail.html_part.decoded).to include(access_log.path)
      expect(mail.html_part.decoded).to include(access_log.timestamp.strftime('%d/%m/%Y à %H:%M:%S'))
    end
  end
end
