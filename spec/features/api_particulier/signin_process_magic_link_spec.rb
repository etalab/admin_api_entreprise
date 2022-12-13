require 'rails_helper'

RSpec.describe 'Signin process via magic link', app: :api_particulier do
  it_behaves_like 'a signin process via magic link'
end
