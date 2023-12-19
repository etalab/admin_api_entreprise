module AuthorizationRequestHelper
  def authorization_request_status_badge(authorization_request)
    "<p class=\"fr-badge fr-mb-1v fr-badge--sm fr-badge--#{authorization_request_status_color(authorization_request)}\">#{authorization_request_status_label(authorization_request)}</p>".html_safe
  end

  def authorization_request_expected_actions(authorization_request, user)
    return [] unless authorization_request.status == 'validated'

    expected_actions = []
    expected_actions << authorization_request_show_action(authorization_request)
    expected_actions << authorization_request_prolong_action(authorization_request, user)
    expected_actions = expected_actions.compact
    expected_actions << no_action if expected_actions.empty?

    expected_actions
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
      label: I18n.t('shared.authorization_requests.index.modal.prolong.display_cta')
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
