require 'rails_helper'

# TODO Move those specs into future contact creation operation
RSpec.describe(Contact::Contract::Upsert) do
  let(:contact_params) { attributes_for :contact }

  describe 'contact creation' do
    let(:contact_form) { described_class.new(Contact.new) }
    let(:errors) { contact_form.errors.messages }

    context 'when params are valid' do
      it 'is valid' do
        contact_form.validate(contact_params)

        expect(errors).to(be_empty)
      end
    end

    describe '#email' do
      let(:err_messages) { errors[:email] }

      it 'is required' do
        contact_params[:email] = nil
        contact_form.validate(contact_params)

        expect(err_messages).to(include('must be filled'))
      end

      it 'has an email format' do
        contact_params[:email] = 'not@nemai1'
        contact_form.validate(contact_params)

        expect(err_messages).to(include('is in invalid format'))
      end
    end

    describe '#phone_number' do
      let(:err_messages) { errors[:phone_number] }

      it 'can be nil' do
        contact_params[:phone_number] = nil
        contact_form.validate(contact_params)

        expect(errors).to(be_empty)
      end

      it 'can be anything' do # We won't validate any phone number format now...
        contact_params[:phone_number] = '+33 coucou lol'
        contact_form.validate(contact_params)

        expect(errors).to(be_empty)
      end
    end

    describe '#contact_type' do
      let(:err_messages) { errors[:contact_type] }

      it 'is required' do
        contact_params[:contact_type] = nil
        contact_form.validate(contact_params)

        expect(err_messages).to(include('must be filled'))
      end

      it 'accepts "admin" value' do
        contact_params[:contact_type] = 'admin'
        contact_form.validate(contact_params)

        expect(errors).to(be_empty)
      end

      it 'accepts "tech" value' do
        contact_params[:contact_type] = 'tech'
        contact_form.validate(contact_params)

        expect(errors).to(be_empty)
      end

      it 'accepts "other" value' do
        contact_params[:contact_type] = 'other'
        contact_form.validate(contact_params)

        expect(errors).to(be_empty)
      end

      it 'does not accept another value' do
        contact_params[:contact_type] = 'nope'
        contact_form.validate(contact_params)

        expect(err_messages).to(include('must be one of: admin, tech, other'))
      end
    end
  end
end
