module User::Contract
  class Update < Reform::Form
    property :note
    property :oauth_api_gouv_id

    validation do
      required(:note).maybe(:str?)
      required(:oauth_api_gouv_id).maybe(:int?)
    end
  end
end
