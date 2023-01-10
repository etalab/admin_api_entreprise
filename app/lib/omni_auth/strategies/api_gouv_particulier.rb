module OmniAuth::Strategies
  class APIGouvParticulier < OmniAuth::Strategies::APIGouvAbstract
    option :name, :api_gouv_particulier
  end
end

OmniAuth::Strategies::ApiGouvParticulier = OmniAuth::Strategies::APIGouvParticulier
