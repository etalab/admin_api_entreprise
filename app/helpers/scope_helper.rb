module ScopeHelper
  def build_scopes(scopes, api)
    scopes_tree = {}
    scopes.each do |scope|
      splitted_scope = humanize_scope(scope, api).split('||').map(&:strip)
      build_scopes_parts(scopes_tree, splitted_scope)
    end
    scopes_tree
  end

  def humanize_scope(scope, api)
    I18n.t("api_#{api}.tokens.token.scope.#{scope}.label", default: scope.humanize)
  end

  private

  def build_scopes_parts(scopes_tree, splitted_scope) # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity
    if splitted_scope.size > 2
      scopes_tree[splitted_scope[0]] ||= {}
      build_scopes_parts(scopes_tree[splitted_scope[0]], splitted_scope[1..])
    elsif splitted_scope.size > 1
      if scopes_tree[splitted_scope[0]].is_a?(Hash)
        scopes_tree[splitted_scope[0]][splitted_scope[1]] ||= []
      else
        scopes_tree[splitted_scope[0]] ||= []
        scopes_tree[splitted_scope[0]].push(splitted_scope[1])
      end
    end
  end
end
