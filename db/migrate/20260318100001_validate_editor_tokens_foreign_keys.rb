class ValidateEditorTokensForeignKeys < ActiveRecord::Migration[8.0]
  def change
    validate_foreign_key :editor_tokens, :editors
  end
end
