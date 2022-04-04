require 'rails_helper'

RSpec.describe API::DatapassWebhooksController, type: :controller do
  describe '#create' do
    subject do
      post :create, params:
    end

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

    let(:event) { 'refused' }

    context 'without a valid hub signature' do
      before do
        allow_any_instance_of(HubSignature).to receive(:valid?).and_return(false)
      end

      it 'does not call DatapassWebhook' do
        expect(DatapassWebhook).not_to receive(:call)

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
        allow_any_instance_of(HubSignature).to receive(:valid?).and_return(true)

        allow(DatapassWebhook).to receive(:call).and_return(
          OpenStruct.new(
            token_id:,
            success?: success
          )
        )
      end

      it 'calls DatapassWebhook' do
        expect(DatapassWebhook).to receive(:call)

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

      context 'when DatapassWebhook fails' do
        let(:success) { false }

        it 'renders 422' do
          subject

          expect(response.code).to eq('422')
        end
      end
    end
  end
end
