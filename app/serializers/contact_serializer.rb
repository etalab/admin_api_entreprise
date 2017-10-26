class ContactSerializer < ActiveModel::Serializer
  attributes :id, :email, :phone_number, :contact_type
end
