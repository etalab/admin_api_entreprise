class Admin::EditorsController < AdminController
  def index
    @editors = Editor.includes(:users).page(params[:page])
  end

  def edit
    @editor = Editor.find(params[:id])
  end

  def update
    @editor = Editor.find(params[:id])

    if @editor.update(editor_update_params)
      success_message(title: 'Éditeur mis à jour')

      redirect_to admin_editors_path
    else
      error_message(title: 'Erreur lors de la mise à jour de l\'éditeur')

      render 'edit', status: :unprocessable_entity
    end
  end

  private

  def editor_update_params
    params.require(:editor).permit(
      :name,
      :form_uids,
      :copy_token
    ).tap do |whitelisted|
      whitelisted[:form_uids] = (whitelisted[:form_uids] || '').split(',').map(&:strip)
    end
  end
end
