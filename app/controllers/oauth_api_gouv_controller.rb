class OAuthApiGouvController < ApplicationController
  skip_before_action :jwt_authenticate!, only: [:login]

  def login

  end
end
