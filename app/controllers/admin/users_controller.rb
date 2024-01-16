class Admin::UsersController < AdminController
  def index
    @users = User.all
  end
end
