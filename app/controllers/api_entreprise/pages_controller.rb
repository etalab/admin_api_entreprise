class APIEntreprise::PagesController < APIEntrepriseController
  helper AlgoliaQueryHelper

  after_action :skip_newsletter_banner!, only: %i[home newsletter]

  layout :page_layout

  def current_status
    @current_status = StatusPage.new.current_status

    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def home
    @endpoints_sample = APIEntreprise::Endpoint.all.sample(3)
    @providers = APIEntreprise::Provider.all
    @cas_usages_sample = APIEntreprise::CasUsage.all.sample(5)
  end

  def newsletter; end

  def cgu; end

  def mentions
    render 'shared/pages/mentions'
  end

  def accessibility
    render 'shared/pages/accessibility'
  end

  def redoc
    render 'shared/pages/redoc'
  end

  private

  def page_layout
    case action_name
    when 'home', 'newsletter'
      'api_entreprise/no_container'
    end
  end

  def skip_newsletter_banner!
    @no_newsletter_banner = true
  end
end
