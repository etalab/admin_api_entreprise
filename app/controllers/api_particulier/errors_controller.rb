class APIParticulier::ErrorsController < APIParticulierController
  include GlobalHTTPErrorsManagement

  layout 'api_particulier/no_container'
end
