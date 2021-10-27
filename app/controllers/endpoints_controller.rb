class EndpointsController < ApplicationController
  def index
    @endpoints = Endpoint.all
  end

  def show
    @endpoint = Endpoint.find(params[:uid])
  end
end
