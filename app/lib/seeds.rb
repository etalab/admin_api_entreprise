class Seeds
  def perform
    create_user(email: 'user@yopmail.com')
    create_user(email: 'api-entreprise@yopmail.com', admin: true)
  end

  private

  def create_user(params={})
    User.create!(
      params,
    )
  end
end
