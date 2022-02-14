class EndpointsController < ApplicationController
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
