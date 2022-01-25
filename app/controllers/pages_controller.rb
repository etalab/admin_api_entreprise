class PagesController < ApplicationController
  def current_status
    @current_status = StatusPage.new.current_status

    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def mentions; end

  def cgu; end

  def redoc; end
end
