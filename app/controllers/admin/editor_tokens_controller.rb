class Admin::EditorTokensController < AdminController
  def create
    @editor = Editor.find(params[:editor_id])

    @editor.editor_tokens.create!(
      iat: Time.zone.now.to_i,
      exp: 18.months.from_now.to_i
    )

    success_message(title: 'Jeton éditeur créé avec succès')
    redirect_to edit_admin_editor_path(@editor)
  end
end
