class APIParticulier::PagesController < APIParticulierController
  layout :page_layout

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
    when 'home'
      'api_particulier/no_container'
    when 'newsletter'
      'api_particulier/no_newsletter_banner'
    end
  end
end
