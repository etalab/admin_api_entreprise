require 'rails_helper'

RSpec.describe(RolesController, type: :controller) do
  describe '#index' do
    let(:nb_roles) { 8 }
    before do
      create_list :role, nb_roles
    end

    it 'returns all roles from the database' do
      get :index
      body = JSON.parse(response.body, symbolize_names: true)

      expect(response.code).to(eq('200'))
      expect(body.size).to(eq(nb_roles))
    end

    it 'returns the right payload format' do
      get :index
      body = JSON.parse(response.body, symbolize_names: true)
      expect(body).to(be_an_instance_of(Array))

      role_raw = body.first
      expect(role_raw).to(be_an_instance_of(Hash))
      expect(role_raw.size).to(eq(3))
      expect(role_raw.key?(:id)).to(be(true))
      expect(role_raw.key?(:name)).to(be(true))
      expect(role_raw.key?(:code)).to(be(true))
    end

    # TODO re-add authorizations for role index (login needed or OAuth application token)
    #context 'when requested from an admin' do
    #  include_context 'admin request'
    #  it_behaves_like 'list roles'
    #end

    #context 'when requested from a client' do
    #  include_context 'user request'
    #  it_behaves_like 'list roles'
    #end
  end

  describe '#create' do
    let(:role_params) { attributes_for :role }

    context 'when requested from an admin' do
      include_context 'admin request'

      context 'when data are valid' do
        it 'creates a valid role' do
          expect { post(:create, params: role_params) }
            .to(change(Role, :count).by(1))
        end

        it 'returns code 201' do
          post :create, params: role_params
          expect(response.code).to(eq('201'))
        end
      end

      context 'when data is invalid' do
        before { role_params[:name] = '' }

        it 'does not save the role' do
          expect { post(:create, params: role_params) }.to_not(change(Role, :count))
        end

        it 'returns code 422' do
          post :create, params: role_params
          expect(response.code).to(eq('422'))
        end
      end
    end

    context 'when requested from a user' do
      include_context 'user request'
      it_behaves_like 'client user unauthorized', :post, :create

      it 'does not save the role' do
        expect { post(:create, params: role_params) }.to_not(change(Role, :count))
      end
    end
  end
end
