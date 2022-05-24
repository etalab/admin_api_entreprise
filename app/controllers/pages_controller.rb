class PagesController < ApplicationController
  layout 'container_fluid', only: :home

  def current_status
    @current_status = StatusPage.new.current_status

    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def home
    @endpoints = Endpoint.all
    @providers = @endpoints.map(&:providers).flatten.uniq
  end

  def mentions; end

  def cgu; end

  def redoc; end
end
