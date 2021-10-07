class ContactSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :email,
    :phone_number,
    :contact_type,
    :jwt_usage_policy,
    :jwt_id
  )

  def jwt_usage_policy
    object.jwt_api_entreprise.try(:displayed_subject)
  end

  def jwt_id
    object.jwt_api_entreprise.try(:id)
  end
end
