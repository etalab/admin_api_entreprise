class EndpointsController < ApplicationController
  layout 'no_container', only: %i[index]

  before_action :extract_endpoint, except: :index

  def index
    @endpoints = Endpoint.all
  end

  def show; end

  def example; end

  private

  def extract_endpoint
    @endpoint = Endpoint.find(params[:uid])
  end
end
