class APIParticulier::ReportersController < APIParticulier::AuthenticatedUsersController
  before_action :check_if_reporter_or_admin

  helper_method :groups_for_reporter

  def index
    @datapasses_for_group_url = MetabaseEmbedService.new(490, { groups: groups_for_reporter.join('|') }).url
  end

  private

  def check_if_reporter_or_admin
    return if current_user.admin? || reporter_emails.include?(current_user.email)

    redirect_to root_path
  end

  def groups_for_reporter
    if current_user.admin?
      reporters_config.keys
    else
      reporters_config.select { |_, emails| emails.include?(current_user.email) }.keys
    end
  end

  def reporter_emails
    reporters_config.values.flatten.uniq
  end

  def reporters_config
    @reporters_config ||= Rails.application.credentials.api_particulier_reporters
  end
end
