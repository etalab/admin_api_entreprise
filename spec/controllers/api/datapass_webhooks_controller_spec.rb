require 'rails_helper'

RSpec.describe API::DatapassWebhooksController do
  let(:params) do
    {
      'event' => event,
      'model_type' => 'Pass',
      'fired_at' => Time.now.to_i.to_s,
      'data' => {
        'pass' => {
          'id' => '9001'
        }
      }
    }
  end

  describe '#api_entreprise' do
    subject do
      post :api_entreprise, params:
    end

    let(:event) { 'refused' }

    context 'without a valid hub signature' do
      before do
        allow_any_instance_of(HubSignature).to receive(:valid?).and_return(false) # rubocop:todo RSpec/AnyInstance
      end

      it 'does not call DatapassWebhook::APIEntreprise' do
        expect(DatapassWebhook::APIEntreprise).not_to receive(:call)

        subject
      end

      it 'renders 401 with an error message as json' do
        subject

        expect(response.code).to eq('401')
        expect(JSON.parse(response.body)).to eq({
          'error' => 'Unauthorized'
        })
      end
    end

    context 'with a valid hub signature' do
      let(:token_id) { 'token id' }
      let(:success) { true }

      before do
        allow_any_instance_of(HubSignature).to receive(:valid?).and_return(true) # rubocop:todo RSpec/AnyInstance

        allow(DatapassWebhook::APIEntreprise).to receive(:call).and_return(
          OpenStruct.new(
            token_id:,
            success?: success
          )
        )
      end

      it 'calls DatapassWebhook::APIEntreprise' do
        expect(DatapassWebhook::APIEntreprise).to receive(:call)

        subject
      end

      it 'tracks through Sentry the incoming payload' do
        allow(Sentry).to receive(:capture_message)
        allow(Sentry).to receive(:set_context)

        expect(Sentry).to receive(:set_context).with(
          'DataPass webhook incoming payload',
          hash_including(
            payload: {
              datapass_id: '9001',
              event:
            }
          )
        )
        expect(Sentry).to receive(:capture_message).with(
          'DataPass Incoming Payload',
          {
            level: 'info'
          }
        )

        subject
      end

      context 'when DatapassWebhook succeed' do
        let(:success) { true }

        it 'renders 200' do
          subject

          expect(response.code).to eq('200')
        end

        context 'when event is validate_application' do
          let(:event) { 'validate_application' }

          it 'renders a json with a token id' do
            subject

            expect(JSON.parse(response.body)['token_id']).to eq(token_id)
          end
        end

        context 'when event is not validate_application' do
          let(:event) { 'whatever' }

          it 'renders an empty json' do
            subject

            expect(JSON.parse(response.body)).to eq({})
          end
        end
      end

      context 'when DatapassWebhook::APIEntreprise fails' do
        let(:success) { false }

        it 'renders 422' do
          subject

          expect(response.code).to eq('422')
        end
      end
    end
  end

  describe '#api_particulier' do
    subject do
      post :api_particulier, params:
    end

    describe 'happy path, on validation' do
      let(:event) { 'validate_application' }
      let(:token_id) { 'token id' }
      let(:success) { true }

      before do
        allow_any_instance_of(HubSignature).to receive(:valid?).and_return(true) # rubocop:todo RSpec/AnyInstance

        allow(DatapassWebhook::APIParticulier).to receive(:call).and_return(
          OpenStruct.new(
            token_id:,
            success?: true
          )
        )
      end

      it 'renders 200' do
        subject

        expect(response.code).to eq('200')
      end

      context 'when event is validate_application' do
        let(:event) { 'validate_application' }

        it 'renders a json with a token id' do
          subject

          expect(JSON.parse(response.body)['token_id']).to eq(token_id)
        end
      end
    end
  end
end
