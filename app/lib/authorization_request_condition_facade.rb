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
end
