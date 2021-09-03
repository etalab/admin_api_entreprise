class AuthorizationRequestConditionFacade < SimpleDelegator
  def all_contacts_have_different_emails?
    [
      user.email,
      contact_technique.email,
      contact_metier.email,
    ].uniq.count == 3
  end

  def all_contacts_have_the_same_email?
    [
      user.email,
      contact_technique.email,
      contact_metier.email,
    ].uniq.count == 1
  end

  def user_is_contact_technique_and_not_contact_metier?
    user.email == contact_technique.email &&
      user.email != contact_metier.email
  end

  def user_is_contact_metier_and_not_contact_technique?
    user.email == contact_metier.email &&
      user.email != contact_technique.email
  end
end
