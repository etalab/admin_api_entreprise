module JwtAPIEntreprise::Operation
  class Update < Trailblazer::Operation
    step Model(JwtAPIEntreprise, :find_by)
    fail :model_not_found, fail_fast: true
    step self::Contract::Build(constant: JwtAPIEntreprise::Contract::Update)
    step self::Contract::Validate()
    step self::Contract::Persist()
    fail :validation_errors

    def validation_errors(ctx, **)
      ctx[:errors] = {} if ctx[:errors].nil?
      ctx[:errors].merge!(ctx['result.contract.default'].errors.messages)
    end

    def model_not_found(ctx, params:, **)
      ctx[:errors] = { jwt_api_entreprise: ["the resource with id `#{params[:id]}` is not found"] }
    end
  end
end
