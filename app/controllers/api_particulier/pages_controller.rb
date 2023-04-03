class APIParticulier::PagesController < APIParticulierController
  def home
    @providers = APIParticulier::Provider.all
  end

  def cgu
    render content_type: 'application/pdf',
      body: File.read(Rails.root.join('public/files/cgu-api-particulier-2022-03.pdf')),
      filename: 'cgu-api-particulier-2022-03.pdf'
  end

  def redoc
    render 'shared/pages/redoc'
  end

  def mentions
    render 'shared/pages/mentions'
  end

  def accessibility
    render 'shared/pages/accessibility'
  end
end
