# Preview all emails at http://localhost:3000/rails/mailers/user
class UserPreview < ActionMailer::Preview
  def confirmation_request
    UserMailer.confirmation_request(User.last)
  end
end
