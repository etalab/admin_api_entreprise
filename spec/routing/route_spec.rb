require 'rails_helper'

RSpec.describe 'Application routes' do
  describe 'roles' do
    it 'has an index route' do
      expect(get('api/admin/roles'))
        .to route_to(controller: 'api/roles', action: 'index')
    end

    it 'has a create route' do
      expect(post('api/admin/roles'))
        .to route_to(controller: 'api/roles', action: 'create')
    end
  end

  describe 'oauth_api_gouv' do
    it 'has a route to login with an authorization code' do
      expect(get('api/admin/oauth_api_gouv/login?authorization_code=very_code'))
        .to route_to(controller: 'api/oauth_api_gouv', action: 'login', authorization_code: 'very_code')
    end

  end

  describe 'users' do
    it 'has an index route' do
      expect(get('api/admin/users'))
        .to route_to(controller: 'api/users', action: 'index')
    end

    it 'has a show route' do
      expect(get('api/admin/users/very_id'))
        .to route_to(controller: 'api/users', action: 'show', id: 'very_id')
    end

    it 'has an update route' do
      expect(patch('api/admin/users/very_id'))
        .to route_to(controller: 'api/users', action: 'update', id: 'very_id')
    end

    it 'has a delete route' do
      expect(delete('api/admin/users/very_id'))
        .to route_to(controller: 'api/users', action: 'destroy', id: 'very_id')
    end

    it 'has an account tranfer route' do
      expect(post('api/admin/users/much_id/transfer_ownership'))
        .to route_to(controller: 'api/users', action: 'transfer_ownership', id: 'much_id')
    end
  end

  describe 'jwt_api_entreprise' do
    it 'has an update route' do
      expect(patch('api/admin/jwt_api_entreprise/very_id'))
        .to route_to(controller: 'api/jwt_api_entreprise', action: 'update', id: 'very_id')
    end

    it 'has a route to create a magic link' do
      expect(post('api/admin/jwt_api_entreprise/very_id/create_magic_link'))
        .to route_to(controller: 'api/jwt_api_entreprise', action: 'create_magic_link', id: 'very_id')
    end

    it 'has an update route' do
      expect(get('api/admin/jwt_api_entreprise/show_magic_link?token=very_token'))
        .to route_to(controller: 'api/jwt_api_entreprise', action: 'show_magic_link', token: 'very_token')
    end
  end
end
