class User::Contract::Update < Reform::Form
  property :note
  property :oauth_api_gouv_id

  validation do
    json do
      required(:note).maybe(:str?)
      required(:oauth_api_gouv_id).maybe(:str?)
    end
  end
end
