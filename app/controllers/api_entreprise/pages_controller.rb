class APIEntreprise::PagesController < APIEntrepriseController
  helper AlgoliaQueryHelper

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
    when 'home'
      'api_entreprise/no_container'
    when 'newsletter'
      'no_newsletter_banner'
    end
  end
end
