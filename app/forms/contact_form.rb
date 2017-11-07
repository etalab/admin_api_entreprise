class ContactForm < Reform::Form
  property :email
  property :phone_number
  property :contact_type

  validation do
    required(:email).filled(format?: /\A[a-zA-Z0-9_.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+\z/)
    required(:phone_number).maybe(format?: /\A0\d(\d{2}){4}\z/)
    required(:contact_type).filled(included_in?: ['admin', 'tech', 'other'])
  end
end
