module GlobalHTTPErrorsManagement
  extend ActiveSupport::Concern

  include Gaffe::Errors

  def show
    render 'errors/show', status: @status_code
  end
end
