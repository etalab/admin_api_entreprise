module User::Operation
  class TransferOwnership < Trailblazer::Operation
    step Model(User, :find_by), Output(:failure) => End(:not_found)
    step :find_new_owner

    fail Subprocess(User::Operation::CreateGhost),
      input: :input_for_ghost_creation,
      output: :output_from_ghost_creation,
      Output(:success) => Track(:success),
      Output(:failure) => End(:invalid_params)

    step :transfer_tokens
    step :send_email_notification


    def find_new_owner(ctx, params:, **)
      ctx[:new_owner] = User.find_by_email(params[:new_owner_email])
    end

    def transfer_tokens(ctx, model:, new_owner:, **)
      new_owner.jwt_api_entreprise << model.jwt_api_entreprise
      model.jwt_api_entreprise.clear
    end

    def send_email_notification(ctx, model:, new_owner:, **)
      UserMailer.transfer_ownership(model, new_owner).deliver_later
    end

    def input_for_ghost_creation(ctx, params:, model:, **)
      {
        params: {
          email: params[:new_owner_email],
          context: model.context
        }
      }
    end

    def output_from_ghost_creation(scoped_ctx, model:, **)
      {
        new_owner: model,
        contract_errors: scoped_ctx['result.contract.default'].errors.messages
      }
    end
  end
end
