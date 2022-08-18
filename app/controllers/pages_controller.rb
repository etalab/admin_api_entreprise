class PagesController < ApplicationController
  helper AlgoliaQueryHelper

  layout :page_layout

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

  def newsletter; end

  def mentions; end

  def cgu; end

  def accessibility; end

  def redoc; end

  private

  def page_layout
    case action_name
    when 'home'
      'no_container'
    when 'newsletter'
      'no_newsletter_banner'
    end
  end
end
