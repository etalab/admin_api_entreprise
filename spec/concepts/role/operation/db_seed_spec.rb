require 'rails_helper'

describe Role::DBSeed do
  let(:roles_seed) do
    [
      { name: 'Role 1', code: 'rol1' },
      { name: 'Role 2', code: 'rol2' }
    ]
  end
  let(:result) { described_class.call({}, roles_seed: roles_seed) }
  let(:log) { result[:log] }

  context 'when roles do not exist' do
    it 'saves them into db' do
      expect { result }.to change(Role, :count).by(2)
    end

    it 'logs role\'s creation' do
      expect(log).to include('Role created : name "Role 1", code "rol1"')
      expect(log).to include('Role created : name "Role 2", code "rol2"')
    end
  end

  context 'when roles already exist in database' do
    before do
      described_class.call({}, roles_seed: roles_seed)
    end

    it 'does not saves the roles' do
      expect { result }.to_not change(Role, :count)
    end

    it 'logs the error' do
      expect(log).to include('Warning role already exists : name "Role 1", code "rol1"')
      expect(log).to include('Warning role already exists : name "Role 2", code "rol2"')
    end
  end
end
