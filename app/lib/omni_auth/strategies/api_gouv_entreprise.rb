module OmniAuth::Strategies
  class APIGouvEntreprise < OmniAuth::Strategies::APIGouvAbstract
    option :name, :api_gouv_entreprise
  end
end

OmniAuth::Strategies::ApiGouvEntreprise = OmniAuth::Strategies::APIGouvEntreprise
