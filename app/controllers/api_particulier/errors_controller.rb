class APIParticulier::ErrorsController < ApplicationController
  include GlobalHTTPErrorsManagement

  layout 'api_particulier/no_container'
end
