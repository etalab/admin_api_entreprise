require 'rails_helper'

RSpec.describe 'Application routes' do
  describe 'incidents' do
    it 'has an index route' do
      expect(get('api/admin/incidents'))
        .to route_to(controller: 'incidents', action: 'index')
    end

    it 'has a create route' do
      expect(post('api/admin/incidents'))
        .to route_to(controller: 'incidents', action: 'create')
    end
    it 'has an update route' do
      expect(put('api/admin/incidents/very_id'))
        .to route_to(controller: 'incidents', action: 'update', id: 'very_id')
    end
  end

  describe 'roles' do
    it 'has an index route' do
      expect(get('api/admin/roles'))
        .to route_to(controller: 'roles', action: 'index')
    end

    it 'has a create route' do
      expect(post('api/admin/roles'))
        .to route_to(controller: 'roles', action: 'create')
    end
  end

  describe 'oauth_api_gouv' do
    it 'has a route to login with an authorization code' do
      expect(get('api/admin/oauth_api_gouv/login?authorization_code=very_code'))
        .to route_to(controller: 'oauth_api_gouv', action: 'login', authorization_code: 'very_code')
    end

  end

  describe 'users' do
    it 'has an index route' do
      expect(get('api/admin/users'))
        .to route_to(controller: 'users', action: 'index')
    end

    it 'has a create route' do
      expect(post('api/admin/users'))
        .to route_to(controller: 'users', action: 'create')
    end

    it 'has a show route' do
      expect(get('api/admin/users/very_id'))
        .to route_to(controller: 'users', action: 'show', id: 'very_id')
    end

    it 'has an update route' do
      expect(patch('api/admin/users/very_id'))
        .to route_to(controller: 'users', action: 'update', id: 'very_id')
    end

    it 'has a delete route' do
      expect(delete('api/admin/users/very_id'))
        .to route_to(controller: 'users', action: 'destroy', id: 'very_id')
    end

    it 'has a login route' do
      expect(post('api/admin/users/login'))
        .to route_to(controller: 'doorkeeper/tokens', action: 'create')
    end

    it 'has an account tranfer route' do
      expect(post('api/admin/users/much_id/transfer_ownership'))
        .to route_to(controller: 'users', action: 'transfer_ownership', id: 'much_id')
    end

    it 'has a password_renewal route' do
      expect(post('api/admin/users/password_renewal'))
        .to route_to(controller: 'users', action: 'password_renewal')
    end

    it 'has a password_reset route' do
      expect(post('api/admin/users/password_reset'))
        .to route_to(controller: 'users', action: 'password_reset')
    end
  end

  describe 'jwt_api_entreprise' do
    it 'has a create route' do
      expect(post('api/admin/users/very_user_id/jwt_api_entreprise'))
        .to route_to(controller: 'jwt_api_entreprise', action: 'create', user_id: 'very_user_id')
    end

    it 'has an update route' do
      expect(patch('api/admin/jwt_api_entreprise/very_id'))
        .to route_to(controller: 'jwt_api_entreprise', action: 'update', id: 'very_id')
    end
  end
end
