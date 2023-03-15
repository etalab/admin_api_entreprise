module ScopeHelper
  def humanize_scope(scope, api)
    I18n.t("api_#{api}.tokens.token.scope.#{scope}", default: scope.humanize)
  end
end
