class PagesController < ApplicationController
  helper AlgoliaQueryHelper

  layout 'no_container', only: %i[home]

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

  def mentions; end

  def cgu; end

  def accessibility; end

  def redoc; end
end
