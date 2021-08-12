module JwtApiEntreprise::Operation
  class Create < Trailblazer::Operation
    step Subprocess(AuthorizationRequest::Operation::FindOrCreateFromJwt),
      input: :input_for_authorization_request_retrieval,
      output: :set_authorization_id

    fail :invalid_authorization_request_params

    step Model(JwtApiEntreprise, :new)
    step self::Contract::Build(constant: JwtApiEntreprise::Contract::Create)
    step self::Contract::Validate()
    step self::Contract::Persist()
    step :set_token_defaults
    step :send_creation_notices

    def input_for_authorization_request_retrieval(ctx, params:)
      @original_params = params

      {
        params: {
          user_id: params[:user_id],
          external_id: params[:authorization_request_id],
          contacts: params[:contacts],
        }
      }
    end

    def set_authorization_id(scoped_ctx, params:, model:, **)
      {
        params: @original_params.merge(
          authorization_request: model,
          authorization_request_operation_contract: scoped_ctx['result.contract.default'],
        ),
      }
    end

    def invalid_authorization_request_params(ctx, params:)
      ctx['result.contract.default'] = params[:authorization_request_operation_contract]
    end

    def set_token_defaults(options, model:, **)
      model.update(
        iat: Time.zone.now.to_i,
        version: '1.0',
        exp: 18.months.from_now.to_i
      )
    end

    def send_creation_notices(_ctx, model:, **)
      JwtApiEntrepriseMailer.creation_notice(model).deliver_later
    end
  end
end
