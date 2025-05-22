# frozen_string_literal: true

require 'rails_helper'
require_relative '../../support/shared_examples/features/show_token_from_magic_link'

RSpec.describe 'show token from magic link', app: :api_entreprise do
  it_behaves_like 'a show token from magic link feature', :token_show_magic_link_path do
    let!(:user) { create(:user, :with_token, email: email) }

    context 'when the magic link token exists' do
      let!(:magic_link) { create(:magic_link, email: email, token: token) }
      let(:magic_token) { magic_link.access_token }

      context 'when the magic token is still active' do
        context 'when it is linked to one token' do
          let(:token_linked) { create(:token) }

          before { magic_link.update!(token_id: token_linked.id) }

          it 'shows only the linked token details' do
            subject

            expect(page).to have_css("##{dom_id(token_linked)}")
          end
        end

        it_behaves_like 'display alert', :info

        it 'displays the expiration time of the magic link' do
          subject
          expiration_time = distance_of_time_in_words(Time.zone.now, magic_link.expires_at)

          expect(page).to have_content(expiration_time)
        end
      end
    end
  end
end
