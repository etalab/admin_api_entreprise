class APIParticulierController < ApplicationController
  layout 'api_particulier/application'

  def namespace
    'api_particulier'
  end

  helper_method :tokens_to_export?

  def tokens_to_export?
    user_signed_in? && TokenExport.new(current_user).tokens_to_export?
  end
end
