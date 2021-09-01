require 'rails_helper'

RSpec.describe DatapassWebhooksController, type: :controller do
  describe '#create' do
    subject do
      post :create, params: params
    end

    let(:params) do
      {
        'event' => event,
        'model_type' => 'Pass',
        'fired_at' => Time.now.to_i.to_s,
        'data' => {
          'pass' => {
            'id' => '9001'
          },
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
          'error' => 'Unauthorized',
        })
      end
    end

    context 'with a valid hub signature' do
      before do
        allow_any_instance_of(HubSignature).to receive(:valid?).and_return(true)
      end

      it 'calls DatapassWebhook' do
        expect(DatapassWebhook).to receive(:call)

        subject
      end

      it 'renders 200' do
        subject

        expect(response.code).to eq('200')
      end

      it 'tracks through Sentry the incoming payload' do
        expect(Sentry).to receive(:set_context).with(
          'DataPass webhook incoming payload',
          payload: params,
        )
        expect(Sentry).to receive(:capture_message).with(
          'DataPass Incoming Payload',
          {
            level: 'info',
          }
        )

        subject
      end
    end
  end
end
