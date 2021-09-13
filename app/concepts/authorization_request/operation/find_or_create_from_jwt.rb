module AuthorizationRequest::Operation
  class FindOrCreateFromJwt < Trailblazer::Operation
    step Model(AuthorizationRequest, :find_or_initialize_by, [:user_id, :authorization_id])
    step self::Contract::Build(constant: AuthorizationRequest::Contract::CreateFromJwt)
    step self::Contract::Validate()
    step self::Contract::Persist()
  end
end
