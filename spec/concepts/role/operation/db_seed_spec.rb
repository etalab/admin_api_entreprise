require 'rails_helper'

describe Role::Operation::DBSeed do
  describe 'with custom roles seed' do
    subject { described_class.call roles_seed: roles_seed }

    let(:roles_seed) do
      [
        { name: 'Role 1', code: 'rol1' },
        { name: 'Role 2', code: 'rol2' }
      ]
    end
    let(:log) { subject[:log] }

    context 'when roles do not exist' do
      it 'saves them into db' do
        expect { subject }.to change(Role, :count).by(2)
      end

      it 'logs role\'s creation' do
        expect(log).to include('Role created : name "Role 1", code "rol1"')
        expect(log).to include('Role created : name "Role 2", code "rol2"')
      end
    end

    context 'when roles already exist in database' do
      before do
        create :role, name: 'Role 1', code: 'rol1'
        create :role, name: 'Role 2', code: 'rol2'
      end

      it 'does not saves the roles' do
        expect { subject }.to_not change(Role, :count)
      end

      it 'logs the error' do
        expect(log).to include('Warning role already exists : name "Role 1", code "rol1"')
        expect(log).to include('Warning role already exists : name "Role 2", code "rol2"')
      end
    end
  end

  describe 'roles_seed defaults to siade roles' do
    subject { described_class.call }

    it 'saves all roles in the database' do
      expect { subject }.to change(Role, :count).by(21)
    end
  end
end
