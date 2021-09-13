require 'rails_helper'

RSpec.describe JwtApiEntreprise::Operation::Create do
  let(:user) { create(:user) }
  let(:roles) { create_list(:role, 7) }
  let(:roles_code) { roles.map { |attr| attr.slice(:code) } }
  let(:token_params) do
    {
      user_id: user.id,
      authorization_request_id: '1234',
      roles: roles_code,
      subject: 'So testy',
      contacts: [
        {
          email: 'coucou@hello.fr',
          phone_number: '0123456789',
          contact_type: 'admin'
        },
        {
          email: 'supsup@hi.yo',
          phone_number: '0987654321',
          contact_type: 'tech'
        }
      ]
    }
  end

  subject { described_class.call(params: token_params) }

  context 'when input data is valid' do
    let(:created_token) { subject[:model] }

    it 'is successful' do
      expect(subject).to be_success
    end

    it 'creates the jwt' do
      expect { subject }.to change(JwtApiEntreprise, :count).by(1)
    end

    it 'belongs to the correct user' do
      expect(created_token.user).to eq(user)
    end

    it 'saves the related authorization request id' do
      expect(created_token.authorization_request_id).to eq(token_params[:authorization_request_id])
    end

    it 'is has the valid access rights' do
      expect(created_token.roles.to_a).to contain_exactly(*roles.to_a)
    end

    it 'expires after 18 months' do
      Timecop.freeze

      expect(created_token.exp).to eq(18.months.from_now.to_i)
      Timecop.return
    end

    it 'has a timestamp of creation' do
      Timecop.freeze

      expect(created_token.iat).to eq(Time.zone.now.to_i)
      Timecop.return
    end

    it 'is saved with a default version number' do
      expect(created_token.version).to eq('1.0')
    end

    it 'creates the related contacts' do
      expect { subject }.to change(Contact, :count).by(2)
    end

    it 'persists valid contacts data' do
      expect(created_token.contacts).to contain_exactly(
        an_object_having_attributes(
          email: 'coucou@hello.fr',
          phone_number: '0123456789',
          contact_type: 'admin'
        ),
        an_object_having_attributes(
          email: 'supsup@hi.yo',
          phone_number: '0987654321',
          contact_type: 'tech'
        )
      )
    end

    describe 'mail notifications' do
      it 'calls the mailer to notice for a JWT creation' do
        expect(JwtApiEntrepriseMailer).to receive(:creation_notice).and_call_original

        subject
      end

      # TODO move into a 'when input is invalid' context group
      it 'does not call the mailer' do
        token_params.delete(:user_id)
        expect(JwtApiEntrepriseMailer).not_to receive(:creation_notice)

        subject
      end
    end
  end

  context 'when input data is invalid' do
    describe ':roles' do
      let(:errors) { subject['result.contract.default'].errors }

      it 'is required' do
        token_params[:roles] = []

        expect(subject).to be_failure
        expect(errors[:roles]).to include 'must be filled'
      end

      it 'fails if provided roles does not exist' do
        token_params[:roles].push({ code: 'ghost_code' })

        expect(subject).to be_failure
        expect(errors[:'roles.code']).to include('role "ghost_code" does not exist')
      end
    end

    describe ':user_id' do
      let(:errors) { subject['result.contract.default'].errors[:user_id] }

      it 'is required' do
        token_params.delete(:user_id)

        expect(subject).to be_failure
        expect(errors).to include('must be filled')
      end

      it 'is an existing user id' do
        token_params[:user_id] = 'not a user id'

        expect(subject).to be_failure
        expect(errors).to include('user with ID "not a user id" does not exist')
      end
    end

    describe ':authorization_request_id (which is renamed external_id)' do
      let(:errors) { subject['result.contract.default'].errors[:external_id] }

      it 'is required' do
        token_params.delete(:authorization_request_id)

        expect(subject).to be_failure
        expect(errors).to include('must be filled')
      end

      it 'is a string' do
        token_params[:authorization_request_id] = true

        expect(subject).to be_failure
        expect(errors).to include('must be a string')
      end
    end

    describe ':subject' do
      let(:errors) { subject['result.contract.default'].errors[:subject] }

      it 'is required' do
        token_params[:subject] = ''

        expect(subject).to be_failure
        expect(errors).to include('must be filled')
      end
    end

    describe ':contacts' do
      let(:errors) { subject['result.contract.default'].errors[:contacts] }

      it 'fails if contact\'s data is not valid' do
        token_params[:contacts].append(email: 'not an email')

        expect(subject).to be_failure
      end

      it 'is required' do
        token_params.delete(:contacts)

        expect(subject).to be_failure
        expect(errors).to include('is missing')
      end

      pending 'business and tech contacts are required'
    end
  end
end
