module User::Operation
  class TransferOwnership < Trailblazer::Operation
    step Model(User, :find_by), Output(:failure) => End(:not_found)
    step :find_new_owner
    fail Contract::Validate(constant: User::Contract::TransferOwnership), Output(:failure) => End(:invalid_params)
    fail :create_new_owner, Output(:success) => Track(:success)
    step :transfer_tokens
    step :send_email_notification


    def find_new_owner(ctx, params:, **)
      ctx[:new_owner] = User.find_by_email(params[:new_owner_email])
    end

    def create_new_owner(ctx, params:, model:, **)
      ctx[:new_owner] = User.create({
        email: params[:new_owner_email],
        context: model.context
      })
    end

    def transfer_tokens(ctx, model:, new_owner:, **)
      new_owner.jwt_api_entreprise << model.jwt_api_entreprise
      model.jwt_api_entreprise.clear
    end

    def send_email_notification(ctx, model:, new_owner:, **)
      UserMailer.transfer_ownership(model, new_owner).deliver_later
    end
  end
end
