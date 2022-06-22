require 'rails_helper'

RSpec.describe 'token tasks', type: :rake do
  include_context 'when using rake mute tasks'

  before { Rails.application.load_tasks }

  describe 'token:blacklist' do
    subject(:run_task) do
      Rake::Task['token:blacklist'].invoke(token_to_blacklist.id)
    end

    let!(:token_to_blacklist) { create :token, :with_scopes }

    it 'creates a duplicated token' do
      expect { run_task }.to change(Token, :count).by(1)

      expect(token_to_blacklist.reload).to be_blacklisted

      new_token = Token.last
      expect(new_token).not_to be(token_to_blacklist)
      expect(Time.zone.at(new_token.iat)).to be_within(1.second).of Time.zone.now

      expect(Token.last.scopes).to eq(token_to_blacklist.scopes)
    end
  end
end
