require 'rails_helper'

RSpec.describe AuthorizationRequestConditionFacade do
  describe 'non regression test: when AuthorizationRequest doesnt have a contact technique' do
    let(:authorization_request) { create(:authorization_request, :with_demandeur) }
    let(:facade) { described_class.new(authorization_request) }

    let(:methods) do
      %i[
        not_editor_and_all_contacts_have_different_emails?
        not_editor_and_all_contacts_have_the_same_email?
        not_editor_and_user_is_contact_technique_and_not_contact_metier?
        not_editor_and_user_is_contact_metier_and_not_contact_technique?
      ]
    end

    it 'does not raise an error' do
      methods.each do |method|
        expect { facade.public_send(method) }.not_to raise_error
      end
    end
  end
end
