class APIParticulier::PagesController < APIParticulierController
  after_action :skip_newsletter_banner!, only: %i[home newsletter]

  layout :page_layout

  def current_status
    @current_status = StatusPage.new(namespace).current_status

    respond_to do |format|
      format.html { render 'shared/pages/current_status', layout: false }
    end
  end

  def home
    @providers = APIParticulier::Provider.all
    @endpoints_sample = APIParticulier::Endpoint.all.sample(3)
  end

  def cgu
    render content_type: 'application/pdf',
      body: Rails.public_path.join('files/cgu-api-particulier-2022-03.pdf').read,
      filename: 'cgu-api-particulier-2022-03.pdf'
  end

  def redoc
    render 'shared/pages/redoc'
  end

  def mentions
    render 'shared/pages/mentions'
  end

  def newsletter; end

  def accessibility
    render 'shared/pages/accessibility'
  end

  private

  def page_layout
    case action_name
    when 'home', 'newsletter'
      'api_particulier/no_container'
    end
  end

  def skip_newsletter_banner!
    @no_newsletter_banner = true
  end
end
