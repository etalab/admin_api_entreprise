class PagesController < ApplicationController
  helper AlgoliaQueryHelper

  layout 'no_container', only: %i[home cas_usages cas_usage]

  def current_status
    @current_status = StatusPage.new.current_status

    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def home
    @endpoints_sample = Endpoint.all.sample(3)
    @providers = Provider.all
  end

  def developers; end

  def cas_usages; end

  def cas_usage
    @cas_usage_name = request.original_url.split('/').last

    @cas_usage = I18n.t("cas_usages.#{@cas_usage_name}")
  end

  def mentions; end

  def cgu; end

  def accessibility; end

  def redoc; end
end
