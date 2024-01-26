# frozen_string_literal: true

class APIParticulier::CasUsagesController < APIParticulierController
  include CasUsagesManagement

  layout 'api_particulier/no_container'
end
