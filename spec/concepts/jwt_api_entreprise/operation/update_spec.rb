require 'rails_helper'

RSpec.describe(JwtApiEntreprise::Operation::Update) do
  subject(:update_jwt!) { described_class.call(params: op_params) }

  context 'when the JWT id is valid' do
    let(:jwt) { create(:jwt_api_entreprise) }
    let(:op_params) { { id: jwt.id, blacklisted: true, archived: true } }

    describe '#blacklisted' do
      it { is_expected.to(be_success) }

      it 'updates the resource' do
        update_jwt!
        jwt.reload

        expect(jwt.blacklisted).to(eq(true))
      end
    end

    describe '#archived' do
      it { is_expected.to(be_success) }

      it 'updates the resource' do
        update_jwt!
        jwt.reload

        expect(jwt.archived).to(eq(true))
      end
    end

    describe 'non-updatable attributes' do
      it { is_expected.to(be_success) }

      it 'does not update the resource' do
        op_params.merge!({
          id: jwt.id,
          subject: 'new subject',
          iat: 9000,
          exp: 10000,
          version: '2.1'
        })
        update_jwt!
        jwt.reload

        expect(jwt.subject).to_not(eq('new subject'))
        expect(jwt.iat).to_not(eq(9000))
        expect(jwt.exp).to_not(eq(10000))
        expect(jwt.version).to_not(eq('2.1'))
      end
    end

    describe 'validations contract' do
      let(:op_params) do
        {
          id: jwt.id,
          blacklisted: true,
          archived: true
        }
      end
      let(:errors) { update_jwt![:errors] }

      describe ':blacklisted' do
        it 'is optional' do
          op_params.delete(:blacklisted)

          expect(update_jwt!).to(be_success)
        end

        it 'must be boolean' do
          op_params[:blacklisted] = 'no bool'

          expect(update_jwt!).to(be_failure)
          expect(errors).to(include(blacklisted: ['must be boolean']))
        end
      end

      describe ':archived' do
        it 'is optional' do
          op_params.delete(:archived)

          expect(update_jwt!).to(be_success)
        end

        it 'must be boolean' do
          op_params[:archived] = 'no bool'

          expect(update_jwt!).to(be_failure)
          expect(errors).to(include(archived: ['must be boolean']))
        end
      end

      context 'when both are absent' do
        it 'is failure' do
          pending 'have not find out how to do it with reform yet'
          op_params.delete(:blacklisted)
          op_params.delete(:archived)

          expect(update_jwt!).to(be_failure)
          expect(errors).to(include('dunno yet'))
        end
      end
    end
  end

  context 'when the JWT id does not exist' do
    let(:op_params) { { id: '0102', blacklisted: true, archived: true } }
    let(:errors) { update_jwt![:errors] }

    it { is_expected.to(be_failure) }

    it 'returns an error message' do
      update_jwt!

      expect(errors).to(include(jwt_api_entreprise: ['the resource with id `0102` is not found']))
    end
  end
end
