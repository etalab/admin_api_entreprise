require 'rails_helper'

describe IncidentsController, type: :controller do
  describe '#index' do
    let(:nb_incidents) { 5 }
    let(:body) { JSON.parse(response.body, symbolize_names: true) }
    before do
      create_list(:incident, nb_incidents)
      get :index
    end

    it 'returns 200' do
      expect(response.code).to eq '200'
    end

    it 'returns the right payload format' do
      expect(body).to be_an_instance_of(Array)
      expect(body.size).to eq(5)

      incident_raw = body.first
      expect(incident_raw).to be_an_instance_of(Hash)
      expect(incident_raw.size).to eq(5)
      expect(incident_raw.key?(:id)).to eq(true)
      expect(incident_raw.key?(:title)).to eq(true)
      expect(incident_raw.key?(:subtitle)).to eq(true)
      expect(incident_raw.key?(:description)).to eq(true)
      expect(incident_raw.key?(:created_at)).to eq(true)
    end
  end

  describe '#create' do
    let(:incident_params) { attributes_for :incident }
    subject { post :create, params: incident_params }

    context 'when requested from a user' do
      include_context 'user request'
      it_behaves_like 'client user unauthorized', :post, :create

      it 'does not save the incident' do
        expect { subject }.to_not change(Incident, :count)
      end
    end

    context 'when requested from an admin' do
      include_context 'admin request'

      context 'when params are valid' do
        it 'returns code 201' do
          subject
          expect(response.code).to eq('201')
        end

        it 'saves the new incident' do
          expect { subject }.to change(Incident, :count).by(1)
        end
      end

      context 'when params are not valid' do
        before { incident_params.delete(:title) }

        it 'does not save the incident' do
          expect { subject }.to_not change(Incident, :count)
        end

        it 'returns 422' do
          subject
          expect(response.code).to eq('422')
        end
      end
    end
  end

  describe '#update' do
    let(:incident) { create(:incident) }
    let(:incident_params) do
      params_update = attributes_for(:incident)
      params_update[:id] = incident.id
      params_update
    end
    subject { post :update, params: incident_params }

    context 'when requested from a user' do
      include_context 'user request'
      it_behaves_like 'client user unauthorized', :post, :create

      it 'does not update the incident' do
        incident_params[:title] = 'Test update'
        subject
        incident.reload

        expect(incident.title).not_to eq('Test update')
      end
    end

    context 'when requested from an admin' do
      include_context 'admin request'

      context 'when params are valid' do
        it 'returns code 200' do
          subject
          expect(response.code).to eq('200')
        end

        it 'updates the incident' do
          incident_params[:title] = 'Updated title'
          subject
          incident.reload

          expect(incident.title).to eq('Updated title')
        end
      end

      # TODO test this the generic way with mock and doubles, test generic operation
      # interfaces for errors
      context 'when params are not valid' do
        before { incident_params[:title] = 'a' * 129 }

        it 'does not update the incident' do
          incident_params[:subtitle] = 'Updated subtitle'
          subject
          incident.reload

          expect(incident.subtitle).not_to eq('Updated subtitle')
        end

        it 'returns 422' do
          subject
          expect(response.code).to eq('422')
        end
      end
    end
  end
end
