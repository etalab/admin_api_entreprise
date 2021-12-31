class RemoveSubjectOnJwtAPIEntreprise < ActiveRecord::Migration[6.1]
  def up
    remove_column :jwt_api_entreprises, :subject, :string
  end

  def down
    add_column :jwt_api_entreprises, :subject, :string

    JwtAPIEntreprise.includes(:authorization_request).find_each do |token|
      token.update(
        subject: token.authorization_request.intitule,
      )
    end
  end
end
