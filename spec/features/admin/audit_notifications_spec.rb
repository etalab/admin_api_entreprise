RSpec.describe 'Admin: audit notifications', app: :api_entreprise do
  let(:admin) { create(:user, :admin) }

  before do
    login_as(admin)
  end

  describe 'index' do
    let!(:audit_notification) { create(:audit_notification) }

    before do
      visit admin_audit_notifications_path
    end

    it 'displays audit notifications' do
      expect(page).to have_content(audit_notification.authorization_request_external_id)
      expect(page).to have_content(audit_notification.reason)
      expect(page).to have_content(audit_notification.request_id_access_logs.size.to_s)
      expect(page).to have_content(audit_notification.contact_emails.join(', '))
    end
  end

  describe 'create' do
    let(:authorization_request) { create(:authorization_request, :with_demandeur) }
    let!(:token) { create(:token, authorization_request: authorization_request) }
    let!(:first_access_log) { create(:access_log, token: token) }
    let!(:second_access_log) { create(:access_log, token: token) }

    before do
      visit new_admin_audit_notification_path
    end

    context 'with valid parameters' do
      it 'creates audit notification and displays success flash' do
        fill_in 'audit_notification_authorization_request_external_id', with: authorization_request.external_id
        fill_in 'audit_notification_reason', with: 'Test audit reason'
        fill_in 'audit_notification_approximate_volume', with: '5000'
        fill_in 'audit_notification_request_id_access_logs_input', with: "#{first_access_log.request_id}\n#{second_access_log.request_id}"

        expect { click_button 'Envoyer la notification' }.to change(AuditNotification, :count).by(1)

        expect(page).to have_css('.fr-alert.fr-alert--success')
        expect(page).to have_current_path(admin_audit_notifications_path)

        audit_notification = AuditNotification.last
        expect(audit_notification.authorization_request_external_id).to eq(authorization_request.external_id)
        expect(audit_notification.reason).to eq('Test audit reason')
        expect(audit_notification.approximate_volume).to eq(5000)
        expect(audit_notification.request_id_access_logs).to contain_exactly(first_access_log.request_id, second_access_log.request_id)
      end
    end

    context 'with invalid parameters' do
      it 'displays form errors' do
        click_button 'Envoyer la notification'

        expect(page).to have_css('.fr-alert.fr-alert--error')
        expect(page).to have_content('Le formulaire contient des erreurs')

        expect(page).to have_content('Identifiant de la demande d\'habilitation doit être rempli(e)')
        expect(page).to have_content('Raison de l\'audit doit être rempli(e)')
        expect(page).to have_content('Identifiants des logs d\'accès doit être rempli(e)')

        expect(AuditNotification.count).to eq(0)
      end
    end
  end
end
