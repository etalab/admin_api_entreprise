class Contact::Contract::Upsert < Reform::Form
  property :email
  property :phone_number
  property :contact_type

  validation do
    json do
      required(:email).filled(format?: ParamsValidation::EmailRegex)
      required(:phone_number).maybe(:str?)
      required(:contact_type).filled(included_in?: %w(admin tech other))
    end
  end
end
