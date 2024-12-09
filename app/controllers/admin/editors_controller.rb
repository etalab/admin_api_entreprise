class Admin::EditorsController < AdminController
  def index
    @editors = Editor.includes(:users).page(params[:page])
  end
end
