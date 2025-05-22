RSpec.shared_examples 'datapass webhooks' do |version|
  it { is_expected.to be_a_success }

  it 'creates one demandeur' do
    expect { subject }.to change(UserAuthorizationRequestRole.where(role: 'demandeur'), :count).by(1)
  end

  it 'creates one contact technique' do
    expect { subject }.to change(UserAuthorizationRequestRole.where(role: 'contact_technique'), :count).by(1)
  end

  it 'calls UpdateOrganizationINSEEPayloadJob' do
    expect(UpdateOrganizationINSEEPayloadJob).to receive(:perform_later).with(a_string_matching(/\A.{14}\z/))

    subject
  end

  it 'creates an authorization request' do
    expect { subject }.to change(AuthorizationRequest, :count).by(1)
  end

  it 'creates a token' do
    expect { subject }.to change(Token, :count).by(1)
  end

  describe 'when all contacts are the same' do
    let(:email) { generate(:email) }

    before do
      if version == 'v2'
        %w[contact_metier contact_technique].each do |role|
          %w[family_name given_name email].each do |attribute|
            datapass_webhook_params['data']['data']["#{role}_#{attribute}"] = datapass_webhook_params['data']['applicant'][attribute]
          end
        end
      else
        datapass_webhook_params['data']['pass']['team_members'].map do |team_member_json|
          team_member_json['family_name'] = 'Dupont'
          team_member_json['given_name'] = 'Jean'
          team_member_json['email'] = email
        end
      end
    end

    it 'creates one demandeur' do
      expect {
        subject
      }.to change(UserAuthorizationRequestRole.where(role: 'demandeur'), :count).by(1)
    end
  end

  describe 'when contact metier is empty (non-regression test)' do
    before do
      if version == 'v2'
        %w[family_name given_name email].each do |attribute|
          datapass_webhook_params['data']['data']["contact_metier_#{attribute}"] = nil
        end
      else
        datapass_webhook_params['data']['pass']['team_members'].each do |team_member_json|
          next unless team_member_json['type'] == 'contact_metier'

          team_member_json['family_name'] = nil
          team_member_json['given_name'] = nil
          team_member_json['email'] = nil
        end
      end
    end

    it 'creates one demandeur' do
      expect {
        subject
      }.to change(UserAuthorizationRequestRole.where(role: 'demandeur'), :count).by(1)
    end

    it 'creates one contact technique' do
      expect {
        subject
      }.to change(UserAuthorizationRequestRole.where(role: 'contact_technique'), :count).by(1)
    end

    it 'does not create contact metier' do
      expect {
        subject
      }.not_to change(UserAuthorizationRequestRole.where(role: 'contact_metier'), :count)
    end
  end

  context 'with a revoke token event' do
    if version == 'v2'
      let(:datapass_webhook_params) { build(:datapass_webhook_v2, event: 'revoke') }
    else
      let(:datapass_webhook_params) { build(:datapass_webhook, event: 'revoke') }
    end

    it { is_expected.to be_a_success }

    it 'does not raise an error' do
      expect { subject }.not_to raise_error
    end
  end

  context 'with an archive token event' do
    if version == 'v2'
      let(:datapass_webhook_params) { build(:datapass_webhook_v2, event: 'archive') }
    else
      let(:datapass_webhook_params) { build(:datapass_webhook, event: 'archive') }
    end

    it { is_expected.to be_a_success }

    it 'does not raise an error' do
      expect { subject }.not_to raise_error
    end
  end

  context 'with a delete token event' do
    if version == 'v2'
      let(:datapass_webhook_params) { build(:datapass_webhook_v2, event: 'delete') }
    else
      let(:datapass_webhook_params) { build(:datapass_webhook, event: 'delete') }
    end

    it { is_expected.to be_a_success }

    it 'does not raise an error' do
      expect { subject }.not_to raise_error
    end
  end
end
