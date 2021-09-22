module FeatureHelpers
  def log_as(user)
    page.set_rack_session(current_user_id: user.id)
  end
end
