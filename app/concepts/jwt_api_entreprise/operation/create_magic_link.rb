module JwtApiEntreprise::Operation
  class CreateMagicLink < Trailblazer::Operation
    step Model(JwtApiEntreprise, :find_by), Output(:failure) => End(:not_found)
    step self::Contract::Validate(constant: JwtApiEntreprise::Contract::CreateMagicLink),
      Output(:failure) => End(:invalid_params), fail_fast: true
    step :generate_magic_link_token
    step :send_magic_link

    def generate_magic_link_token(ctx, model:, **)
      model.generate_magic_link_token
    end

    def send_magic_link(ctx, model:, params:, **)
      JwtApiEntrepriseMailer.magic_link(params[:email], model).deliver_later
    end
  end
end
