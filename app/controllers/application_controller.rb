class ApplicationController < ActionController::Base
  include UserSessionsHelpers

  layout 'application'
end
