module SessionsManagement # rubocop:disable Metrics/ModuleLength
  extend ActiveSupport::Concern

  ALLOWED_OAUTH_PROVIDERS = %w[
    proconnect_api_entreprise
    proconnect_api_particulier
  ].freeze

  BYPASS_LOGIN_ENVIRONMENTS = %w[development staging sandbox].freeze

  MON_COMPTE_PRO_IDP_ID = '71144ab3-ee1a-4401-b7b3-79b44f7daeeb'.freeze

  included do
    before_action :validate_oauth_callback!, only: [:create_from_oauth]
  end

  def new
    redirect_current_user_to_homepage if user_signed_in?
  end

  def create_from_oauth
    return redirect_to_mfa_reauthentication if requires_mfa_reauthentication?

    interactor_call = User::ProconnectLogin.call(user_params:)

    login(interactor_call)
  end

  def failure
    error_message(title: t(".#{failure_message}", default: t('.unknown')))

    redirect_to login_path
  end

  def destroy
    logout_user

    redirect_to after_logout_path,
      allow_other_host: true
  end

  def after_logout
    success_message(title: t('.success'))

    redirect_to root_path
  end

  def dev_login
    unless BYPASS_LOGIN_ENVIRONMENTS.include?(Rails.env.to_s)
      redirect_to root_path
      return
    end

    user = User.find_by(email: params[:email]&.downcase)

    if user
      sign_in_and_redirect(user)
    else
      error_message(title: 'Compte introuvable')
      redirect_to root_path
    end
  end

  private

  def after_logout_path
    "/auth/proconnect_#{namespace}/logout"
  end

  def validate_oauth_callback!
    unless ALLOWED_OAUTH_PROVIDERS.include?(params[:provider])
      track_invalid_provider_attempt
      redirect_to(login_path) and return
    end

    return if request.env['omniauth.auth']

    track_missing_omniauth_data
    redirect_to(login_path) and return
  end

  def track_invalid_provider_attempt
    MonitoringService.instance.track(
      'OAuth security: Invalid provider attempt',
      level: 'info',
      context: {
        provider: params[:provider],
        ip: request.remote_ip
      }
    )
  end

  def track_missing_omniauth_data
    MonitoringService.instance.track(
      'OAuth security: Missing OmniAuth data',
      level: 'info',
      context: {
        provider: params[:provider],
        ip: request.remote_ip
      }
    )
  end

  def user_params
    request.env['omniauth.auth'].info.slice('email', 'last_name', 'first_name', 'uid')
  end

  def login(interactor_call)
    if interactor_call.success?
      sign_in_and_redirect(interactor_call.user)
    else
      send(extract_flash_kind(interactor_call.message), title: t(".#{interactor_call.message}.title"), description: t(".#{interactor_call.message}.description", email: oauth_email))

      redirect_to login_path
    end
  end

  def failure_message
    params[:message]
  end

  def extract_flash_kind(message)
    case message
    when 'not_found'
      'info_message'
    else
      'error_message'
    end
  end

  def redirect_to_mfa_reauthentication
    type = namespace.delete_prefix('api_')
    uri = OmniAuth::Strategies::Proconnect.authorization_uri_with_mfa(
      type,
      session: session,
      login_hint: raw_info['email']
    )
    redirect_to uri, allow_other_host: true
  end

  def requires_mfa_reauthentication?
    raw_info['idp_id'] == MON_COMPTE_PRO_IDP_ID &&
      id_token_amr.exclude?('mfa')
  end

  def id_token_amr
    id_token = session['omniauth.pc.id_token']
    return [] unless id_token

    claims = JSON::JWT.decode(id_token, :skip_verification)
    Array(claims['amr'])
  end

  def raw_info
    request.env.dig('omniauth.auth', 'extra', 'raw_info') || {}
  end
end
