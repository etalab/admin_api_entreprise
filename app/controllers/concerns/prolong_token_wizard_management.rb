module ProlongTokenWizardManagement
  extend ActiveSupport::Concern

  include Wicked::Wizard

  include ExternalUrlHelper
  include DsfrStepperHelper

  included do
    steps :owner, :project_purpose, :contacts, :summary
    before_action :find_token
    before_action :find_prolong_token_wizard, only: %i[start show update finished]
    before_action :redirect_to_finished, only: %i[start show]
    before_action :redirect_to_build, only: %i[finished]
  end

  def start
    redirect_to token_prolong_build_path(token_id: @token.id, id: @prolong_token_wizard.status || 'owner')
  end

  def show
    render_step "shared/prolong_token_wizard/#{step}"
  end

  def finished
    @prolong_token_wizard.finish!

    if @prolong_token_wizard.prolonged?
      render 'shared/prolong_token_wizard/prolonged'
    else
      redirect_to datapass_reopen_authorization_request_url(@prolong_token_wizard.token.authorization_request, @prolong_token_wizard), allow_other_host: true
    end
  end

  def update
    @prolong_token_wizard.update(prolong_token_wizard_params.merge({ status: step }))

    render_wizard @prolong_token_wizard
  end

  private

  def redirect_to_build
    redirect_to token_prolong_build_path(token_id: @token.id, id: @prolong_token_wizard.status || 'owner') unless @prolong_token_wizard.after?(:contacts)
  end

  def redirect_to_finished
    redirect_to token_prolong_finished_path(token_id: @token.id) if @prolong_token_wizard.after?(:finished)
  end

  def find_token
    @token = Token.find(params[:token_id])
    authorize @token, :prolong?
  end

  def find_prolong_token_wizard
    @prolong_token_wizard = @token.current_prolong_token_wizard
  end

  def prolong_token_wizard_params
    params.expect(prolong_token_wizard: %i[owner project_purpose contact_metier contact_technique])
  end
end
