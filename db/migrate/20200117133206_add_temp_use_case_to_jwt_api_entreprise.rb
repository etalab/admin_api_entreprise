class AddTempUseCaseToJwtApiEntreprise < ActiveRecord::Migration[6.0]
  def change
    add_column :jwt_api_entreprises, :temp_use_case, :string, default: nil

    # Fetching JWT where the subject equals to a SIRET number so we can set
    # the new and temporary attribute to it's user context (containing the
    # actual use case of the token).
    jwt_to_update = JwtApiEntreprise.where.not(user_id: nil).where("subject ~ '\\d{14}'")
    jwt_to_update.each { |j| j.update(temp_use_case: j.user.context) }
  end
end
