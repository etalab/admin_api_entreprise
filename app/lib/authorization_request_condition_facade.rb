class AuthorizationRequestConditionFacade < SimpleDelegator
  def not_editor_and_all_contacts_have_different_emails?
    not_editor_authorization_request &&
      [
        demandeur.email,
        contact_technique.email,
        contact_metier.email
      ].uniq.count == 3
  end

  def not_editor_and_all_contacts_have_the_same_email?
    not_editor_authorization_request &&
      [
        demandeur.email,
        contact_technique.email,
        contact_metier.email
      ].uniq.count == 1
  end

  def not_editor_and_user_is_contact_technique_and_not_contact_metier?
    not_editor_authorization_request &&
      demandeur.email == contact_technique.email &&
      demandeur.email != contact_metier.email
  end

  def not_editor_and_user_is_contact_metier_and_not_contact_technique?
    not_editor_authorization_request &&
      demandeur.email == contact_metier.email &&
      demandeur.email != contact_technique.email
  end

  def editor_authorization_request
    demarche == 'editeurs'
  end

  def not_editor_authorization_request
    !editor_authorization_request
  end
end
