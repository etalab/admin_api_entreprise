module AuthorizationRequestHelper
  def authorization_request_status_badge(authorization_request)
    "<p class=\"fr-badge fr-mb-1v fr-badge--sm fr-badge--#{authorization_request_status_color(authorization_request)}\">#{authorization_request_status_label(authorization_request)}</p>".html_safe
  end

  def authorization_request_expected_actions(authorization_request, user)
    return [] if authorization_request.status != 'validated' || authorization_request.token.nil?

    expected_actions = []
    expected_actions << authorization_request_show_action(authorization_request)
    expected_actions << authorization_request_prolong_action(authorization_request, user)
    expected_actions = expected_actions.compact
    expected_actions << no_action if expected_actions.empty?

    expected_actions
  end

  def prolong_token_label(token)
    return I18n.t('shared.prolong_token_wizard.display_cta') if token.last_prolong_token_wizard.nil?
    return I18n.t('shared.prolong_token_wizard.requires_update_cta') if token.last_prolong_token_wizard.requires_update?
    return I18n.t('shared.prolong_token_wizard.updates_requested_cta') if token.last_prolong_token_wizard.updates_requested?

    I18n.t('shared.prolong_token_wizard.display_cta')
  end

  def should_redirect_to_datapass(token)
    token.last_prolong_token_wizard.present? &&
      (token.last_prolong_token_wizard.requires_update? ||
      token.last_prolong_token_wizard.updates_requested?)
  end

  private

  def no_action
    {
      action: 'no_action',
      label: I18n.t('shared.authorization_requests.index.no_action')
    }
  end

  def authorization_request_prolong_action(authorization_request, user)
    return unless TokenPolicy.new(user, authorization_request.token).prolong?

    {
      action: 'prolong',
      label: prolong_token_label(authorization_request.token),
      to_datapass_reopen: should_redirect_to_datapass(authorization_request.token)
    }
  end

  def authorization_request_show_action(authorization_request)
    if authorization_request.tokens.blacklisted_later.any?
      {
        action: 'show',
        label: I18n.t('shared.authorization_requests.index.modal.show.display_cta_replace')
      }
    elsif !authorization_request.token.used? && authorization_request.token.active?
      {
        action: 'show',
        label: I18n.t('shared.authorization_requests.index.modal.show.display_cta_new_token')
      }
    elsif authorization_request.token.legacy_token? && !authorization_request.token.legacy_token_migrated?
      {
        action: 'show',
        label: I18n.t('shared.authorization_requests.index.modal.show.display_cta_replace_legacy')
      }
    end
  end

  def authorization_request_status_color(authorization_request)
    I18n.t("shared.authorization_requests.status.color.#{authorization_request.status}")
  end

  def authorization_request_status_label(authorization_request)
    I18n.t("shared.authorization_requests.status.label.#{authorization_request.status}")
  end
end
