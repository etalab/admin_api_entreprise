class CreateAuthorizationRequests < ActiveRecord::Migration[6.1]
  def up
    create_table :authorization_requests, id: :uuid do |t|
      t.string :intitule
      t.string :description
      t.string :external_id
      t.string :status
      t.datetime :last_update
      t.datetime :first_submitted_at
      t.datetime :validated_at
      t.datetime :created_at

      t.uuid :user_id, null: false
    end

    add_column :contacts, :authorization_request_id, :uuid
    add_column :jwt_api_entreprises, :authorization_request_model_id, :uuid

    JwtAPIEntreprise.where.not(authorization_request_id: nil).find_each do |jwt_api_entreprise|
      authorization_request = AuthorizationRequest.create!(
        intitule: jwt_api_entreprise.subject,
        external_id: jwt_api_entreprise.authorization_request_id,
        status: 'validate_application',
        last_update: jwt_api_entreprise.created_at,
        validated_at: jwt_api_entreprise.created_at,
        user_id: jwt_api_entreprise.user_id,
      )

      Contact.where(jwt_api_entreprise_id: jwt_api_entreprise.id).each do |contact|
        contact.update!(
          authorization_request_id: authorization_request.id,
        )
      end

      jwt_api_entreprise.update!(
        authorization_request_model_id: authorization_request.id,
      )
    end
  end

  def down
    drop_table :authorization_requests

    remove_column :contacts, :authorization_request_id, :uuid
    remove_column :jwt_api_entreprises, :authorization_request_model_id, :uuid
  end
end
