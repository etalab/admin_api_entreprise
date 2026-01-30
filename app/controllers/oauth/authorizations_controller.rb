class OAuth::AuthorizationsController < Doorkeeper::AuthorizationsController
  layout 'api_entreprise/application'

  helper ExternalUrlHelper
  helper ScopeHelper
  helper_method :namespace

  before_action :load_available_tokens, only: %i[new create] # rubocop:disable Rails/LexicallyScopedActionFilter

  def new
    if pre_auth.authorizable?
      if skip_authorization? || (matching_token? && !force_consent?)
        auth = authorization.authorize
        URI.parse(auth.redirect_uri)
        session.delete(:prompt)
        redirect_or_render(auth)
      else
        render :new
      end
    else
      render :error
    end
  end

  def namespace
    'api_entreprise'
  end

  private

  def force_consent?
    true
  end

  def authorize_response
    @authorize_response ||= super.tap do |response|
      persist_token_selection(response)
    end
  end

  def persist_token_selection(response)
    grant = response.try(:auth)&.token
    return unless grant.is_a?(Doorkeeper::AccessGrant)

    grant.update(token_ids: selected_token_ids)
  end

  def selected_token_ids
    Array(params[:token_ids]).compact_blank
  end

  def load_available_tokens
    @available_tokens = current_user ? current_user.tokens.active_for('entreprise') : []
  end
end
