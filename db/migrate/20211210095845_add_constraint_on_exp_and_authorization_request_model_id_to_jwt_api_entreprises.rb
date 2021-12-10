class AddConstraintOnExpAndAuthorizationRequestModelIdToJwtAPIEntreprises < ActiveRecord::Migration[6.1]
  def change
    change_column_null :jwt_api_entreprises, :exp, false
    change_column_null :jwt_api_entreprises, :authorization_request_model_id, false
  end
end
