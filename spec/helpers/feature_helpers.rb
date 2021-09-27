module FeatureHelpers
  def login_as(user)
    page.set_rack_session(current_user_id: user.id)
  end
end
