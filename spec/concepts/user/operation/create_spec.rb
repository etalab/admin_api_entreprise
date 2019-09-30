require 'rails_helper'

describe User::Operation::Create do
  let(:result) { described_class.call(params: user_params) }
  let(:user_email) { 'new@record.gg' }
  let(:user_params) do
    {
      email: user_email,
      context: 'very development',
      note: 'Much notes very commercial data',
      allow_token_creation: true,
      contacts: [
        {
          email: 'coucou@hello.fr',
          phone_number: '0123456789',
          contact_type: 'tech'
        },
        {
          email: 'supsup@hi.yo',
          phone_number: nil,
          contact_type: 'other'
        }
      ]
    }
  end

  context 'when params are valid' do
    it 'creates the new user' do
      expect { result }.to change(User, :count).by(1)
      expect(result).to be_success
      expect(result[:model]).to have_attributes(
        email: user_email,
        context: 'very development',
        note: 'Much notes very commercial data',
        allow_token_creation: true,
      )
    end

    it 'creates the associated contacts' do
      expect { result }.to change(Contact, :count).by(2)
    end
  end

  context 'when params are invalid' do
    describe '#email' do
      let(:errors) do
        result['result.contract.default'].errors.messages[:email]
      end

      it 'is required' do
        user_params[:email] = ''

        expect(result).to be_failure
        expect(errors).to include 'must be filled'
      end

      it 'has an email format' do
        user_params[:email] = 'verymail'

        expect(result).to be_failure
        expect(errors).to include 'is in invalid format'
      end

      it 'is unique' do
        user = create(:user)
        user_params[:email] = user.email

        expect(result).to be_failure
        expect(errors).to include 'value already exists'
      end

      it 'is saved lowercase' do
        user_params[:email] = 'COUCOU@COUCOU.FR'

        expect(result).to be_success
        expect(result[:model].email).to eq 'coucou@coucou.fr'
      end
    end

    describe '#context' do
      let(:errors) do
        result['result.contract.default'].errors.messages[:context]
      end

      it 'can be blank' do
        user_params[:context] = ''

        expect(result).to be_success
        expect(errors).to be_nil
      end
    end

    describe '#note' do
      it 'is optional' do
        user_params.delete(:note)

        expect(result).to be_success
      end
    end

    describe '#contacts' do
      it 'is not valid if contact\'s data is not valid' do
        user_params[:contacts].append(email: 'not an email')

        expect(result).to be_failure
      end

      it 'is optionnal' do
        user_params.delete :contacts

        expect(result).to be_success
      end
    end

    describe '#allow_token_creation' do
      let(:errors) { result['result.contract.default'].errors.messages[:allow_token_creation] }

      context 'when provided' do
        it 'is a boolean value' do
          user_params[:allow_token_creation] = 'truedat'

          expect(result).to be_failure
          expect(errors).to include('must be boolean')
        end
      end

      context 'when not provided' do
        it 'still works' do
          user_params.delete(:allow_token_creation)

          expect(result).to be_success
        end

        it 'is default to false' do
          user_params.delete(:allow_token_creation)
          created_user = result[:model]

          expect(created_user.allow_token_creation).to eq(false)
        end
      end
    end

    describe 'account created state' do
      let(:created_user) { result[:model] }

      it 'sets the password to an empty string' do
        expect(created_user.password_digest).to eq ''
      end

      it 'sets a token for future email confirmation' do
        expect(created_user.confirmation_token)
          .to match(/\A[0-9a-f]{20}\z/)
      end

      it 'is not confirmed' do
        expect(created_user).to_not be_confirmed
      end

      it 'sets the confirmation request timestamp' do
        expect(result[:model].confirmation_sent_at.to_i).to be_within(2).of(Time.zone.now.to_i)
      end

      describe 'mail notifications' do
        before do
          allow(UserMailer).to receive(:confirm_account_action).and_call_original
          allow(UserMailer).to receive(:confirm_account_notice).and_call_original
        end

        it 'sends account confirmation email to contact principal' do
          expect(UserMailer).to receive(:confirm_account_action)
            .with(an_object_having_attributes(email: user_email, class: User))
          result
        end

        it 'sends needed action notice email to each contacts' do
          expect(UserMailer).to receive(:confirm_account_notice)
            .with(an_object_having_attributes(email: user_email, class: User))
          result
        end

        it 'do not send confirm account notice when there is no contact' do
          user_params[:contacts].clear
          expect(UserMailer).not_to receive(:confirm_account_notice)
          result
          expect(result).to be_success
        end

        it 'do not send confirm account notice when all contacts are the same' do
          user_params[:contacts].each { |contact| contact[:email] = user_email }
          expect(UserMailer).not_to receive(:confirm_account_notice)
          result
          expect(result).to be_success
        end
      end
    end
  end
end
